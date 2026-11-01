import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_details_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/entities/news_entity.dart';
import 'package:al_mahhaba_school/features/news/domain/repos/news_repo.dart';

@LazySingleton(as: NewsRepo)
class NewsRepoImpl implements NewsRepo {
  NewsRepoImpl(this._remoteDataSource);

  final NewsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<NewsEntity>>> getNews() =>
      Result.guard(_remoteDataSource.getNews);

  @override
  Future<Result<NewsDetailsEntity>> getNewsDetails(String slug) =>
      Result.guard(() => _remoteDataSource.getNewsDetails(slug));
}
