import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.label,
    required this.price,
    required this.period,
    required this.renewalNote,
    this.badge,
  });

  final String id;

  /// "Monthly" / "Yearly".
  final String label;

  /// "$9.99".
  final String price;

  /// "/ month".
  final String period;

  /// "Then $9.99/month · cancel anytime".
  final String renewalNote;

  /// "Save 33%".
  final String? badge;
}

@immutable
class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    required this.freeScansLeft,
    this.planId,
  });

  final bool isPremium;
  final int freeScansLeft;
  final String? planId;

  bool get canScan => isPremium || freeScansLeft > 0;

  PremiumStatus copyWith({
    bool? isPremium,
    int? freeScansLeft,
    String? planId,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      freeScansLeft: freeScansLeft ?? this.freeScansLeft,
      planId: planId ?? this.planId,
    );
  }
}

/// Store abstraction — RevenueCat (or StoreKit) slots in behind this.
abstract interface class PurchaseRepository {
  Future<List<SubscriptionPlan>> fetchPlans();
  Future<PremiumStatus> fetchStatus();
  Future<PremiumStatus> purchase(String planId);
  Future<PremiumStatus> restore();

  /// Records one identification against the free allowance.
  Future<PremiumStatus> consumeScan();
}
