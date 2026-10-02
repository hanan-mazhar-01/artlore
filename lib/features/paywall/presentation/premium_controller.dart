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

  @override
  Future<PremiumStatus> build() =>
      ref.watch(purchaseRepositoryProvider).fetchStatus();

  /// Returns true when the visitor is premium afterwards.
  Future<bool> purchase(String planId) async {
    final status = await _repo.purchase(planId);
    state = AsyncData(status);
    return status.isPremium;
  }

  Future<bool> restore() async {
    final status = await _repo.restore();
    state = AsyncData(status);
    return status.isPremium;
  }

  Future<void> consumeScan() async {
    state = AsyncData(await _repo.consumeScan());
  }
}
