import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

/// The selected child's latest result; success with null before any is
/// published.
typedef ResultsState = BaseState<ResultDetailsEntity?>;
