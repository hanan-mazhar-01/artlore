import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/services/device_id_service.dart';
import '../domain/premium_models.dart';

/// Production-ready RevenueCat implementation of [PurchaseRepository].
///
/// Configured for:
/// - Entitlement: `pro`
/// - Monthly Product: `artlore_pro_monthly`
/// - Yearly Product: `artlore_pro_yearly`
class RevenueCatPurchaseRepository implements PurchaseRepository {
  RevenueCatPurchaseRepository({
    required this.deviceIdService,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _customAuth = auth,
       _customFirestore = firestore;

  final DeviceIdService deviceIdService;
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  static const monthlyProductId = 'artlore_pro_monthly';
  static const yearlyProductId = 'artlore_pro_yearly';
  static const entitlementId = 'pro';

  static const guestAllowance = 3;
  static const accountBonusAllowance = 3;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (_isFirebaseReady) return FirebaseAuth.instance;
    return null;
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (_isFirebaseReady) return FirebaseFirestore.instance;
    return null;
  }

  DocumentReference<Map<String, dynamic>> _entitlementDoc(
    FirebaseFirestore firestore,
    String uid,
  ) => firestore.collection('entitlements').doc(uid);

  DocumentReference<Map<String, dynamic>> _deviceDoc(
    FirebaseFirestore firestore,
    String deviceId,
  ) => firestore.collection('deviceTrials').doc(deviceId);

  /// One free trial per device. Ignored in debug builds so test accounts on
  /// the same phone each get a fresh allowance.
  static bool _isDeviceBlocked(Map<String, dynamic>? data) =>
      !kDebugMode && (data?['deviceBlocked'] as bool? ?? false);

  PremiumStatus _statusFromData(
    Map<String, dynamic>? data, {
    required bool isAnonymous,
    required bool isRevenueCatPremium,
    String? planId,
    bool isTrial = false,
  }) {
    final scansUsed = (data?['scansUsed'] as num?)?.toInt() ?? 0;
    final accountBonusGranted = data?['accountBonusGranted'] as bool? ?? false;
    final deviceBlocked = _isDeviceBlocked(data);

    // Premium comes from RevenueCat's entitlement and nowhere else — never
    // from a value the visitor's own device could write, and it lapses the
    // moment the entitlement does.
    final isPremium = isRevenueCatPremium;
    final activePlanId = isPremium ? planId : null;
    final activeTrial = isPremium && isTrial;

    final allowance = deviceBlocked
        ? 0
        : guestAllowance + (accountBonusGranted ? accountBonusAllowance : 0);
    final freeScansLeft = isPremium
        ? 0
        : (allowance - scansUsed).clamp(0, allowance);
    final requiresAccount = !isPremium && isAnonymous && freeScansLeft == 0;

    return PremiumStatus(
      isPremium: isPremium,
      freeScansLeft: freeScansLeft,
      requiresAccount: requiresAccount,
      planId: activePlanId,
      isTrial: activeTrial,
    );
  }

  Future<Map<String, dynamic>> _ensureEntitlementDoc(
    FirebaseFirestore firestore,
    String uid,
  ) async {
    final ref = _entitlementDoc(firestore, uid);
    final snap = await ref.get();
    if (snap.exists) return snap.data()!;

    final deviceId = await deviceIdService.getDeviceId();
    final deviceRef = _deviceDoc(firestore, deviceId);
    final deviceSnap = await deviceRef.get();
    final alreadyConsumed =
        deviceSnap.data()?['trialConsumed'] as bool? ?? false;

    final fresh = <String, dynamic>{
      'scansUsed': 0,
      'accountBonusGranted': false,
      'deviceBlocked': alreadyConsumed,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.set(fresh);
    if (!alreadyConsumed) {
      await deviceRef.set({
        'trialConsumed': true,
        'firstUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return fresh;
  }

  Future<({bool isPremium, String? planId, bool isTrial})>
  _checkRevenueCatPremium() async {
    if (kIsWeb) return (isPremium: false, planId: null, isTrial: false);
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final ent = customerInfo.entitlements.all[entitlementId];
      final isPremium = ent?.isActive == true;
      final planId = isPremium ? ent?.productIdentifier : null;
      final isTrial =
          isPremium &&
          (ent?.periodType == PeriodType.trial ||
              ent?.periodType == PeriodType.intro);
      return (isPremium: isPremium, planId: planId, isTrial: isTrial);
    } catch (e) {
      debugPrint('RevenueCat: check premium error: $e');
      return (isPremium: false, planId: null, isTrial: false);
    }
  }

  @override
  Future<PremiumStatus> fetchStatus() async {
    final rcInfo = await _checkRevenueCatPremium();
    final isRcPremium = rcInfo.isPremium;
    final rcPlanId = rcInfo.planId;
    final rcIsTrial = rcInfo.isTrial;

    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;

    if (auth == null || firestore == null || user == null) {
      return PremiumStatus(
        isPremium: isRcPremium,
        freeScansLeft: isRcPremium ? 0 : guestAllowance,
        planId: rcPlanId,
        isTrial: rcIsTrial,
      );
    }

    Map<String, dynamic> data;
    try {
      data = await _ensureEntitlementDoc(firestore, user.uid);
    } catch (e) {
      // The server refused or could not be reached: carry on with the free
      // allowance rather than leaving the app waiting.
      debugPrint('RevenueCat: entitlement read/create failed: $e');
      return PremiumStatus(
        isPremium: isRcPremium,
        freeScansLeft: isRcPremium ? 0 : guestAllowance,
        planId: rcPlanId,
        isTrial: rcIsTrial,
      );
    }

    return _statusFromData(
      data,
      isAnonymous: user.isAnonymous,
      isRevenueCatPremium: isRcPremium,
      planId: rcPlanId,
      isTrial: rcIsTrial,
    );
  }

  /// Days in a store intro-offer period.
  static int _days(int units, PeriodUnit unit) => switch (unit) {
    PeriodUnit.day => units,
    PeriodUnit.week => units * 7,
    PeriodUnit.month => units * 30,
    PeriodUnit.year => units * 365,
    PeriodUnit.unknown => 0,
  };

  /// The plans exactly as the store sells them: price, period and — only
  /// when the product really has a free introductory period *and* this
  /// Apple ID is still eligible for it — the trial. Nothing is hard-coded;
  /// if the store can't be reached there are no plans, and the paywall says
  /// so rather than showing prices of its own.
  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    if (kIsWeb) return const [];
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? const [];
      if (packages.isEmpty) return const [];

      final ids = [for (final p in packages) p.storeProduct.identifier];
      Map<String, IntroEligibility> eligibility = const {};
      try {
        eligibility = await Purchases.checkTrialOrIntroductoryPriceEligibility(
          ids,
        );
      } catch (e) {
        debugPrint('RevenueCat: eligibility check failed: $e');
      }

      final plans = <SubscriptionPlan>[];
      for (final package in packages) {
        final p = package.storeProduct;
        final isYearly =
            package.packageType == PackageType.annual ||
            p.identifier.contains('yearly') ||
            p.identifier.contains('annual');

        final intro = p.introductoryPrice;
        final eligible =
            eligibility[p.identifier]?.status ==
            IntroEligibilityStatus.introEligibilityStatusEligible;
        final freeTrial = intro != null && intro.price == 0 && eligible;
        final trialDays = freeTrial
            ? _days(intro.periodNumberOfUnits, intro.periodUnit)
            : 0;

        final per = isYearly ? 'year' : 'month';
        final renewalNote = trialDays > 0
            ? '$trialDays days free, then ${p.priceString}/$per'
            : '${p.priceString}/$per';

        plans.add(
          SubscriptionPlan(
            id: p.identifier,
            label: isYearly ? 'Yearly' : 'Monthly',
            price: p.priceString,
            period: isYearly ? '/ year' : '/ month',
            renewalNote: renewalNote,
            badge: trialDays > 0
                ? '$trialDays days free'
                : (isYearly ? 'Best value' : null),
            hasTrial: trialDays > 0,
            trialDays: trialDays,
          ),
        );
      }

      // Monthly first, then yearly.
      plans.sort(
        (a, b) => (a.label == 'Monthly' ? 0 : 1).compareTo(
          b.label == 'Monthly' ? 0 : 1,
        ),
      );
      return plans;
    } catch (e) {
      debugPrint('RevenueCat: fetchPlans error: $e');
      return const [];
    }
  }

  @override
  Future<PremiumStatus> purchase(String planId) async {
    if (!kIsWeb) {
      try {
        final offerings = await Purchases.getOfferings();
        final current = offerings.current;
        Package? packageToBuy;

        if (current != null) {
          for (final pkg in current.availablePackages) {
            if (pkg.storeProduct.identifier == planId ||
                pkg.identifier == planId) {
              packageToBuy = pkg;
              break;
            }
          }
        }

        if (packageToBuy != null) {
          await Purchases.purchase(PurchaseParams.package(packageToBuy));
        } else {
          final products = await Purchases.getProducts([planId]);
          if (products.isEmpty) return await fetchStatus();
          await Purchases.purchase(PurchaseParams.storeProduct(products.first));
        }

        // The purchase is confirmed by RevenueCat's customer info; nothing
        // about it is stored on our side.
        return await fetchStatus();
      } catch (e) {
        debugPrint('RevenueCat: purchase error: $e');
        rethrow;
      }
    }

    return fetchStatus();
  }

  @override
  Future<PremiumStatus> restore() async {
    if (!kIsWeb) {
      try {
        await Purchases.restorePurchases();
      } on PlatformException catch (e) {
        debugPrint('RevenueCat: restore error: $e');
        rethrow;
      }
    }

    return fetchStatus();
  }

  @override
  Future<PremiumStatus> consumeScan() async {
    final rcInfo = await _checkRevenueCatPremium();
    if (rcInfo.isPremium) {
      return PremiumStatus(
        isPremium: true,
        freeScansLeft: 0,
        planId: rcInfo.planId,
        isTrial: rcInfo.isTrial,
      );
    }

    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (auth == null || firestore == null || user == null) {
      return const PremiumStatus(isPremium: false, freeScansLeft: 0);
    }

    await _ensureEntitlementDoc(firestore, user.uid);
    final ref = _entitlementDoc(firestore, user.uid);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;
      final deviceBlocked = _isDeviceBlocked(data);
      final accountBonusGranted = data['accountBonusGranted'] as bool? ?? false;
      final allowance = deviceBlocked
          ? 0
          : guestAllowance + (accountBonusGranted ? accountBonusAllowance : 0);
      final current = (data['scansUsed'] as num?)?.toInt() ?? 0;
      if (current >= allowance) return;
      tx.update(ref, {'scansUsed': current + 1});
    });

    final snap = await ref.get();
    return _statusFromData(
      snap.data(),
      isAnonymous: user.isAnonymous,
      isRevenueCatPremium: false,
    );
  }

  @override
  Future<void> grantAccountBonusIfEligible() async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (auth == null || firestore == null || user == null) return;

    final ref = _entitlementDoc(firestore, user.uid);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;
      final already = data['accountBonusGranted'] as bool? ?? false;
      if (already) return;
      tx.update(ref, {'accountBonusGranted': true});
    });
  }
}
