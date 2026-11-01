import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/repos/news_repo.dart';

/// Loads one article: `final result = await getNewsDetails(slug);`
@lazySingleton
class GetNewsDetailsUseCase {
  GetNewsDetailsUseCase(this._repo);

  final NewsRepo _repo;

  Future<Result<NewsDetailsEntity>> call(String slug) =>
      _repo.getNewsDetails(slug);
}
