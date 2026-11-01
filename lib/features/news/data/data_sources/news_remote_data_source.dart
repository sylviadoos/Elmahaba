import 'package:al_mahhaba_school/features/news/data/models/news_details_model.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_model.dart';

/// Reads news from the school API. Throws an `AppException` on failure.
abstract interface class NewsRemoteDataSource {
  /// Latest news first, as sent by the API.
  Future<List<NewsModel>> getNews();

  /// One article by its slug. A missing article fails with a 404
  /// `ServerException` ("News item not found.").
  Future<NewsDetailsModel> getNewsDetails(String slug);
}
