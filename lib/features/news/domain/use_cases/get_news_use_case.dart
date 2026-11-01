import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/repos/news_repo.dart';

/// Loads the school news list: `final result = await getNews();`
@lazySingleton
class GetNewsUseCase {
  GetNewsUseCase(this._repo);

  final NewsRepo _repo;

  Future<Result<List<NewsEntity>>> call() => _repo.getNews();
}
