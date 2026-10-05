import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/services/device_id_service.dart';
import '../domain/premium_models.dart';

/// Live store-backed repository using Google Play Billing / StoreKit via
/// the official `in_app_purchase` plugin, with the free-scan entitlement
/// tracked server-side in Firestore (per account, with a one-time
/// per-device trial cap — see [DeviceIdService]).
///
/// Requires these product IDs to exist in Play Console and App Store
/// Connect before purchases will resolve — [monthlyProductId] and
/// [yearlyProductId] as auto-renewing subscriptions.
///
/// Scan allowance: 3 free scans as a guest, then a sign-up wall; signing up
/// (or linking a guest session to a real account) grants 3 more before the
/// paywall. A fresh account created without ever being a guest starts with
/// the base 3. Once a device has granted a trial, deleting and re-creating
/// an account — or returning to guest mode — on the same device grants no
/// further free scans.
class InAppPurchaseRepository implements PurchaseRepository {
  InAppPurchaseRepository({
    required this.deviceIdService,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _customAuth = auth,
        _customFirestore = firestore {
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) => debugPrint('InAppPurchaseRepository: stream error: $e'),
    );
  }

  final DeviceIdService deviceIdService;
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final InAppPurchase _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  Completer<PremiumStatus>? _pendingCompleter;

  static const monthlyProductId = 'artlore_premium_monthly';
  static const yearlyProductId = 'artlore_premium_yearly';
  static const _productIds = {monthlyProductId, yearlyProductId};

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

  void dispose() => _subscription.cancel();

  DocumentReference<Map<String, dynamic>> _entitlementDoc(
    FirebaseFirestore firestore,
    String uid,
  ) => firestore.collection('entitlements').doc(uid);

  DocumentReference<Map<String, dynamic>> _deviceDoc(
    FirebaseFirestore firestore,
    String deviceId,
  ) => firestore.collection('deviceTrials').doc(deviceId);

  PremiumStatus _statusFromData(Map<String, dynamic>? data, {required bool isAnonymous}) {
    final scansUsed = (data?['scansUsed'] as num?)?.toInt() ?? 0;
    final accountBonusGranted = data?['accountBonusGranted'] as bool? ?? false;
    final deviceBlocked = data?['deviceBlocked'] as bool? ?? false;
    final isPremium = data?['isPremium'] as bool? ?? false;
    final planId = data?['planId'] as String?;

    final allowance = deviceBlocked
        ? 0
        : guestAllowance + (accountBonusGranted ? accountBonusAllowance : 0);
    final freeScansLeft = isPremium ? 0 : (allowance - scansUsed).clamp(0, allowance);
    final requiresAccount = !isPremium && isAnonymous && freeScansLeft == 0;

    return PremiumStatus(
      isPremium: isPremium,
      freeScansLeft: freeScansLeft,
      requiresAccount: requiresAccount,
      planId: planId,
    );
  }

  /// Reads the caller's entitlement doc, creating it — gated by this
  /// device's one-time trial — if it doesn't exist yet.
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
    final alreadyConsumed = deviceSnap.data()?['trialConsumed'] as bool? ?? false;

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

  @override
  Future<PremiumStatus> fetchStatus() async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (auth == null || firestore == null || user == null) {
      return const PremiumStatus(isPremium: false, freeScansLeft: guestAllowance);
    }
    final data = await _ensureEntitlementDoc(firestore, user.uid);
    return _statusFromData(data, isAnonymous: user.isAnonymous);
  }

  @override
  Future<PremiumStatus> consumeScan() async {
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
      final accountBonusGranted = data['accountBonusGranted'] as bool? ?? false;
      final allowance = deviceBlocked
          ? 0
          : guestAllowance + (accountBonusGranted ? accountBonusAllowance : 0);
      final current = (data['scansUsed'] as num?)?.toInt() ?? 0;
      if (current >= allowance) return;
      tx.update(ref, {'scansUsed': current + 1});
    });

    final snap = await ref.get();
    return _statusFromData(snap.data(), isAnonymous: user.isAnonymous);
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

  /// Shown until real products exist in Play Console / App Store Connect
  /// (or this is swapped for RevenueCat) — lets the paywall work end to end
  /// for now, with [_grantPremiumDirectly] backing the "subscribe" button.
  static const _fallbackPlans = [
    SubscriptionPlan(
      id: monthlyProductId,
      label: 'Monthly',
      price: r'$9.99',
      period: '/ month',
      renewalNote: r'Then $9.99/month · cancel anytime',
    ),
    SubscriptionPlan(
      id: yearlyProductId,
      label: 'Yearly',
      price: r'$49.99',
      period: '/ year',
      renewalNote: r'Then $49.99/year · cancel anytime',
      badge: 'Best value',
    ),
  ];

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async {
    if (!await _iap.isAvailable()) return _fallbackPlans;

    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('InAppPurchaseRepository: queryProductDetails failed: ${response.error}');
    }
    if (response.productDetails.isEmpty) return _fallbackPlans;

    return response.productDetails.map((product) {
      final isYearly = product.id == yearlyProductId;
      return SubscriptionPlan(
        id: product.id,
        label: isYearly ? 'Yearly' : 'Monthly',
        price: product.price,
        period: isYearly ? '/ year' : '/ month',
        renewalNote:
            'Then ${product.price}${isYearly ? '/year' : '/month'} · cancel anytime',
        badge: isYearly ? 'Best value' : null,
      );
    }).toList();
  }

  @override
  Future<PremiumStatus> purchase(String planId) async {
    final available = await _iap.isAvailable();
    final response = available
        ? await _iap.queryProductDetails({planId})
        : null;

    // Real store products aren't set up in Play Console / App Store Connect
    // yet — grant the plan directly so the paywall is usable for now. Once
    // real products exist (or this is swapped for RevenueCat), this branch
    // stops being reachable and the real purchase flow below takes over.
    if (response == null || response.productDetails.isEmpty) {
      return _grantPremiumDirectly(planId);
    }

    final completer = Completer<PremiumStatus>();
    _pendingCompleter = completer;

    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: response.productDetails.first),
      );
    } catch (e) {
      debugPrint('InAppPurchaseRepository: purchase failed to start: $e');
      _pendingCompleter = null;
      return fetchStatus();
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: fetchStatus,
    );
  }

  Future<PremiumStatus> _grantPremiumDirectly(String planId) async {
    final auth = _auth;
    final firestore = _firestore;
    final user = auth?.currentUser;
    if (auth == null || firestore == null || user == null) {
      return const PremiumStatus(isPremium: true, freeScansLeft: 0);
    }
    await _ensureEntitlementDoc(firestore, user.uid);
    await _entitlementDoc(firestore, user.uid).update({
      'isPremium': true,
      'planId': planId,
    });
    return fetchStatus();
  }

  @override
  Future<PremiumStatus> restore() async {
    final completer = Completer<PremiumStatus>();
    _pendingCompleter = completer;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('InAppPurchaseRepository: restore failed to start: $e');
      _pendingCompleter = null;
      return fetchStatus();
    }

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: fetchStatus,
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          debugPrint('InAppPurchaseRepository: purchase error: ${purchase.error}');
          _pendingCompleter?.complete(await fetchStatus());
          _pendingCompleter = null;
          break;
        case PurchaseStatus.canceled:
          _pendingCompleter?.complete(await fetchStatus());
          _pendingCompleter = null;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final auth = _auth;
          final firestore = _firestore;
          final user = auth?.currentUser;
          if (firestore != null && user != null) {
            await _ensureEntitlementDoc(firestore, user.uid);
            await _entitlementDoc(firestore, user.uid).update({
              'isPremium': true,
              'planId': purchase.productID,
            });
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _pendingCompleter?.complete(await fetchStatus());
          _pendingCompleter = null;
          break;
      }
    }
  }
}
