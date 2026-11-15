import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_item_entity.dart';

/// An online payment, started: the payment page to open, and what it
/// pays.
class CheckoutEntity extends Equatable {
  const CheckoutEntity({
    required this.checkoutUrl,
    required this.sessionId,
    required this.items,
    required this.total,
  });

  /// Skoolex Pay's page, where the parent pays.
  final String checkoutUrl;
  final String sessionId;
  final List<CheckoutItemEntity> items;

  /// In EGP.
  final double total;

  @override
  List<Object?> get props => [checkoutUrl, sessionId, items, total];
}
