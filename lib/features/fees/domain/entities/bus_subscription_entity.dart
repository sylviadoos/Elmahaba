import 'package:equatable/equatable.dart';

/// The child's bus subscription request.
class BusSubscriptionEntity extends Equatable {
  const BusSubscriptionEntity({
    required this.available,
    required this.status,
    this.amount,
    this.rejectionReason,
  });

  /// Whether the parent can ask for one.
  final bool available;

  /// As the API names it, e.g. "NONE".
  final String status;

  /// In EGP; null when there's none.
  final double? amount;

  /// Why the school turned it down, if it did.
  final String? rejectionReason;

  @override
  List<Object?> get props => [available, status, amount, rejectionReason];
}
