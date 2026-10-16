import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/premium_models.dart';

/// Available plans from the store.
final plansProvider = FutureProvider<List<SubscriptionPlan>>(
  (ref) => ref.watch(purchaseRepositoryProvider).fetchPlans(),
);

/// Entitlement + free scan allowance.
final premiumProvider = AsyncNotifierProvider<PremiumController, PremiumStatus>(
  PremiumController.new,
);

class PremiumController extends AsyncNotifier<PremiumStatus> {
  PurchaseRepository get _repo => ref.read(purchaseRepositoryProvider);

  /// Debug builds only, for testing: a guest can scan as often as they like,
  /// and no free scans are spent on the real account. Release builds are
  /// untouched — they always follow the store and the server.
  static PremiumStatus _forTesting(PremiumStatus status) => kDebugMode
      ? status.copyWith(freeScansLeft: 999, requiresAccount: false)
      : status;

  @override
  Future<PremiumStatus> build() async =>
      _forTesting(await ref.watch(purchaseRepositoryProvider).fetchStatus());

  /// Returns true when the visitor is premium afterwards.
  Future<bool> purchase(String planId) async {
    final status = _forTesting(await _repo.purchase(planId));
    state = AsyncData(status);
    return status.isPremium;
  }

  Future<bool> restore() async {
    final status = _forTesting(await _repo.restore());
    state = AsyncData(status);
    return status.isPremium;
  }

  Future<void> consumeScan() async {
    // Testing in debug: don't spend the account's real free scans.
    if (kDebugMode) return;
    state = AsyncData(await _repo.consumeScan());
  }

  /// Re-reads entitlement from the repository — call after any sign-in,
  /// sign-up or sign-out, since the active Firebase UID (and therefore the
  /// entitlement doc behind it) just changed.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(_forTesting(await _repo.fetchStatus()));
  }
}
