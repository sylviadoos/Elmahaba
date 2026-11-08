import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_details_model.dart';
import 'package:al_mahhaba_school/features/news/data/models/news_model.dart';

@LazySingleton(as: NewsRemoteDataSource)
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  NewsRemoteDataSourceImpl(@Named(ApiNames.website) this._api);

  final ApiService _api;

  @override
  Future<List<NewsModel>> getNews() async {
    // { "status": "success", "data": [ ...news ] }
    final json = await _api.get(ApiEndpoints.news) as Map<String, dynamic>;
    final data = json[ApiKeys.data] as List<dynamic>;
    return data
        .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NewsDetailsModel> getNewsDetails(String slug) async {
    // { "status": "success", "data": { ...news, "content_html": "..." } }
    final json =
        await _api.get(ApiEndpoints.newsDetails(slug)) as Map<String, dynamic>;
    return NewsDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }
}
