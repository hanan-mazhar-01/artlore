import '../domain/premium_models.dart';

/// Simulated store: purchases succeed after a short pause, restore finds
/// nothing unless a purchase was made in this session.
class MockPurchaseRepository implements PurchaseRepository {
  MockPurchaseRepository({this.latency = const Duration(milliseconds: 900)});

  final Duration latency;
  PremiumStatus _status = const PremiumStatus(
    isPremium: false,
    freeScansLeft: 3,
  );

  static const _plans = [
    SubscriptionPlan(
      id: 'monthly',
      label: 'Monthly',
      price: r'$9.99',
      period: '/ month',
      renewalNote: r'Then $9.99/month · cancel anytime',
    ),
    SubscriptionPlan(
      id: 'yearly',
      label: 'Yearly',
      price: r'$79.99',
      period: '/ year',
      renewalNote: r'Then $79.99/year · cancel anytime',
      badge: 'Save 33%',
    ),
  ];

  @override
  Future<List<SubscriptionPlan>> fetchPlans() async => _plans;

  @override
  Future<PremiumStatus> fetchStatus() async => _status;

  @override
  Future<PremiumStatus> purchase(String planId) async {
    await Future<void>.delayed(latency);
    return _status = _status.copyWith(isPremium: true, planId: planId);
  }

  @override
  Future<PremiumStatus> restore() async {
    await Future<void>.delayed(latency);
    return _status;
  }

  @override
  Future<PremiumStatus> consumeScan() async {
    if (_status.isPremium || _status.freeScansLeft == 0) return _status;
    return _status = _status.copyWith(freeScansLeft: _status.freeScansLeft - 1);
  }
}
