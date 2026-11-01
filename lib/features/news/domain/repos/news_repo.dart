import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';

/// News for visitors. Never throws — errors come back as a `Failure`.
abstract interface class NewsRepo {
  /// Latest news first.
  Future<Result<List<NewsEntity>>> getNews();

  /// One full article by its slug.
  Future<Result<NewsDetailsEntity>> getNewsDetails(String slug);
}
