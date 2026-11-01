import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_cubit.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/use_cases/get_news_use_case.dart';
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_event.dart';

typedef NewsState = BaseState<List<NewsEntity>>;

/// Drives the News page. No navigation actions yet, hence `void`.
@injectable
class NewsViewModel extends BaseCubit<NewsState, NewsEvent, void> {
  NewsViewModel(this._getNews) : super(const NewsState.initial());

  final GetNewsUseCase _getNews;

  @override
  Future<void> doAction(NewsEvent event) async {
    switch (event) {
      case GetNewsEvent():
        await _loadNews();
    }
  }

  Future<void> _loadNews() async {
    emit(const NewsState.loading());
    final result = await _getNews();
    if (isClosed) return;
    emit(
      result.when(
        success: (news) => NewsState.success(news),
        failure: (exception) => NewsState.error(exception),
      ),
    );
  }
}
