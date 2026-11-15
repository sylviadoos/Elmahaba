import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';

/// Starting an online payment; on success, the page to pay on.
typedef PayFeesState = BaseState<CheckoutEntity>;
