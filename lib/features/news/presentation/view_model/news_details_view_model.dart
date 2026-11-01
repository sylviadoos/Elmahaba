import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/use_cases/get_news_details_use_case.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_details_event.dart';

typedef NewsDetailsState = BaseState<NewsDetailsEntity>;

/// Drives the news article page. No navigation actions yet, hence `void`.
@injectable
class NewsDetailsViewModel
    extends BaseCubit<NewsDetailsState, NewsDetailsEvent, void> {
  NewsDetailsViewModel(this._getNewsDetails)
    : super(const NewsDetailsState.initial());

  final GetNewsDetailsUseCase _getNewsDetails;

  @override
  Future<void> doAction(NewsDetailsEvent event) async {
    switch (event) {
      case GetNewsDetailsEvent(:final slug):
        await _loadDetails(slug);
    }
  }

  Future<void> _loadDetails(String slug) async {
    emit(const NewsDetailsState.loading());
    final result = await _getNewsDetails(slug);
    if (isClosed) return;
    emit(
      result.when(
        success: (details) => NewsDetailsState.success(details),
        failure: (exception) => NewsDetailsState.error(exception),
      ),
    );
  }
}
