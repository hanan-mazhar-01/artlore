import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  })  : _customAuth = auth,
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
  ) =>
      firestore.collection('entitlements').doc(uid);

  DocumentReference<Map<String, dynamic>> _deviceDoc(
    FirebaseFirestore firestore,
    String deviceId,
  ) =>
      firestore.collection('deviceTrials').doc(deviceId);

  PremiumStatus _statusFromData(
    Map<String, dynamic>? data, {
    required bool isAnonymous,
    required bool isRevenueCatPremium,
    String? planId,
  }) {
    final scansUsed = (data?['scansUsed'] as num?)?.toInt() ?? 0;
    final accountBonusGranted = data?['accountBonusGranted'] as bool? ?? false;
    final deviceBlocked = data?['deviceBlocked'] as bool? ?? false;
    final firestorePremium = data?['isPremium'] as bool? ?? false;

    final isPremium = isRevenueCatPremium || firestorePremium;
    final activePlanId = planId ?? data?['planId'] as String?;

    final allowance = deviceBlocked
        ? 0
        : guestAllowance + (accountBonusGranted ? accountBonusAllowance : 0);
    final freeScansLeft =
        isPremium ? 0 : (allowance - scansUsed).clamp(0, allowance);
    final requiresAccount = !isPremium && isAnonymous && freeScansLeft == 0;

    return PremiumStatus(
      isPremium: isPremium,
      freeScansLeft: freeScansLeft,
      requiresAccount: requiresAccount,
      planId: activePlanId,
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
      'isPremium': false,
      'planId': null,
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

  Future<bool> _checkRevenueCatPremium() async {
    if (kIsWeb) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('RevenueCat: check premium error: $e');
      return false;
    }
  }

  @override
  Future<PremiumStatus> fetchStatus() async {
    final isRcPremium = await _checkRevenueCatPremium();

    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;

    if (auth == null || firestore == null || user == null) {
      return PremiumStatus(
        isPremium: isRcPremium,
        freeScansLeft: isRcPremium ? 0 : guestAllowance,
      );
    }

    final data = await _ensureEntitlementDoc(firestore, user.uid);
    if (isRcPremium && (data['isPremium'] as bool? ?? false) == false) {
      try {
        await _entitlementDoc(firestore, user.uid).update({'isPremium': true});
      } catch (_) {}
    }

    return _statusFromData(
      data,
      isAnonymous: user.isAnonymous,
      isRevenueCatPremium: isRcPremium,
    );
  }

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    const fallbackPlans = [
      SubscriptionPlan(
        id: monthlyProductId,
        label: 'Monthly',
        price: r'$4.99',
        period: '/ month',
        renewalNote: r'3 days free, then $4.99/month · cancel anytime',
        badge: '3 days free',
        hasTrial: true,
        trialDays: 3,
      ),
      SubscriptionPlan(
        id: yearlyProductId,
        label: 'Yearly',
        price: r'$29.99',
        period: '/ year',
        renewalNote: r'Then $29.99/year · cancel anytime',
        badge: 'Best value',
        hasTrial: false,
        trialDays: 0,
      ),
    ];

    if (kIsWeb) return fallbackPlans;

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return fallbackPlans;
      }

      final plans = <SubscriptionPlan>[];
      for (final package in current.availablePackages) {
        final p = package.storeProduct;
        final isYearly = p.identifier.contains('yearly') ||
            p.identifier.contains('annual') ||
            package.packageType == PackageType.annual;
        final isMonthly = p.identifier.contains('monthly') ||
            package.packageType == PackageType.monthly;

        final hasTrial = isMonthly || (p.introductoryPrice != null);
        final trialDays = isMonthly ? 3 : 0;
        final badge = isMonthly ? '3 days free' : (isYearly ? 'Best value' : null);
        final renewalNote = hasTrial && trialDays > 0
            ? '3 days free, then ${p.priceString}/month · cancel anytime'
            : (isYearly
                ? 'Then ${p.priceString}/year · cancel anytime'
                : 'Then ${p.priceString}/month · cancel anytime');

        plans.add(
          SubscriptionPlan(
            id: p.identifier,
            label: isYearly ? 'Yearly' : 'Monthly',
            price: p.priceString,
            period: isYearly ? '/ year' : '/ month',
            renewalNote: renewalNote,
            badge: badge,
            hasTrial: hasTrial,
            trialDays: trialDays,
          ),
        );
      }

      // Sort so Monthly is first, Yearly is second
      plans.sort((a, b) => a.id.contains('monthly') ? -1 : 1);
      return plans.isNotEmpty ? plans : fallbackPlans;
    } catch (e) {
      debugPrint('RevenueCat: fetchPlans error: $e');
      return fallbackPlans;
    }
  }

  @override
  Future<PremiumStatus> purchase(String planId) async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;

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

        final CustomerInfo customerInfo;
        if (packageToBuy != null) {
          final res = await Purchases.purchase(
            PurchaseParams.package(packageToBuy),
          );
          customerInfo = res.customerInfo;
        } else {
          final products = await Purchases.getProducts([planId]);
          if (products.isNotEmpty) {
            final res = await Purchases.purchase(
              PurchaseParams.storeProduct(products.first),
            );
            customerInfo = res.customerInfo;
          } else {
            return await fetchStatus();
          }
        }

        final isPremium =
            customerInfo.entitlements.all[entitlementId]?.isActive == true;

        if (isPremium && firestore != null && user != null) {
          await _entitlementDoc(firestore, user.uid).set({
            'isPremium': true,
            'planId': planId,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

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
        final customerInfo = await Purchases.restorePurchases();
        final isPremium =
            customerInfo.entitlements.all[entitlementId]?.isActive == true;

        final auth = _auth;
        final firestore = _firestore;
        final user = auth?.currentUser;

        if (isPremium && firestore != null && user != null) {
          await _entitlementDoc(firestore, user.uid).set({
            'isPremium': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('RevenueCat: restore error: $e');
      }
    }

    return fetchStatus();
  }

  @override
  Future<PremiumStatus> consumeScan() async {
    final isRcPremium = await _checkRevenueCatPremium();
    if (isRcPremium) {
      return const PremiumStatus(isPremium: true, freeScansLeft: 0);
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
      final isPremium = data['isPremium'] as bool? ?? false;
      if (isPremium) return;
      final deviceBlocked = data['deviceBlocked'] as bool? ?? false;
      final accountBonusGranted =
          data['accountBonusGranted'] as bool? ?? false;
      final allowance = deviceBlocked
          ? 0
          : guestAllowance +
              (accountBonusGranted ? accountBonusAllowance : 0);
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
