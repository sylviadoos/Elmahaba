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

  /// On offer but not on the statement yet: the school lists it apart,
  /// and it counts in no total until the parent adds it. One that's been
  /// added is a mandatory line with [canDelete].
  final bool isOptional;
  final bool isPaid;

  /// Whether the parent can drop it again — an optional fee they added,
  /// with nothing paid on it yet.
  final bool canDelete;

  @override
  List<Object?> get props => [
    id,
    name,
    bankAccount,
    amount,
    isOptional,
    isPaid,
    canDelete,
  ];
}
