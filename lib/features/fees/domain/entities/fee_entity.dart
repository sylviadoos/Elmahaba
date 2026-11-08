import 'package:equatable/equatable.dart';

/// A fee on the statement, e.g. tuition or the bus.
class FeeEntity extends Equatable {
  const FeeEntity({
    this.id,
    required this.name,
    required this.bankAccount,
    required this.amount,
    required this.isOptional,
    required this.isPaid,
    required this.canDelete,
    this.isSubscribed,
  });

  /// null for a line the school adds up from several fees, e.g.
  /// "مصاريف التعليم والنشاط".
  final int? id;

  /// As the school wrote it, e.g. "رسوم كتب".
  final String name;

  /// The bank account it's paid into, masked, e.g. "••••••••/446".
  final String bankAccount;

  /// In EGP; may have piasters (1.5).
  final double amount;

  /// Counts only once the parent subscribes to it.
  final bool isOptional;
  final bool isPaid;

  /// Whether the parent can drop it, e.g. the bus subscription.
  final bool canDelete;

  /// For an optional fee, whether the child is subscribed; null when the
  /// school doesn't say.
  final bool? isSubscribed;

  @override
  List<Object?> get props => [
    id,
    name,
    bankAccount,
    amount,
    isOptional,
    isPaid,
    canDelete,
    isSubscribed,
  ];
}
