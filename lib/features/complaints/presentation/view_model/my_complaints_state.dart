import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';

/// The complaints loaded so far. While the next page loads it's
/// `moreLoading`; if that fails it's `error` and still holds them.
typedef MyComplaintsState = BaseState<ComplaintsPageEntity>;
