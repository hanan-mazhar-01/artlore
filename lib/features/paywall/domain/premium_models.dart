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
    this.hasTrial = false,
    this.trialDays = 0,
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

  /// "3 days free" / "Save 33%".
  final String? badge;

  /// True if plan comes with a free trial.
  final bool hasTrial;

  /// Free trial length in days (e.g. 3).
  final int trialDays;
}

@immutable
class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    required this.freeScansLeft,
    this.requiresAccount = false,
    this.planId,
  });

  final bool isPremium;
  final int freeScansLeft;

  /// True once a guest (anonymous) visitor has used their free scans and
  /// must create an account or sign in to keep exploring — shown before the
  /// paywall, not instead of it.
  final bool requiresAccount;
  final String? planId;

  bool get canScan => isPremium || freeScansLeft > 0;

  PremiumStatus copyWith({
    bool? isPremium,
    int? freeScansLeft,
    bool? requiresAccount,
    String? planId,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      freeScansLeft: freeScansLeft ?? this.freeScansLeft,
      requiresAccount: requiresAccount ?? this.requiresAccount,
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

  /// Call right after a guest account is upgraded to a real one (linked,
  /// not replaced) to grant the one-time bonus scans for signing up.
  /// A no-op if the bonus was already granted or there's no guest history.
  Future<void> grantAccountBonusIfEligible();
}
