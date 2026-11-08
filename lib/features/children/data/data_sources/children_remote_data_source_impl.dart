import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_remote_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_details_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_child_request_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_child_result_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

@LazySingleton(as: ChildrenRemoteDataSource)
class ChildrenRemoteDataSourceImpl implements ChildrenRemoteDataSource {
  ChildrenRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<List<ChildModel>> getChildren() async {
    // { "status": "success", "data": [ ...children ] }
    final json = await _api.get(ApiEndpoints.children) as Map<String, dynamic>;
    final data = json[ApiKeys.data] as List<dynamic>;
    return data
        .map((item) => ChildModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChildDetailsModel> getChildDetails(int childId) async {
    // { "status": "success", "data": { …details… } }
    final json =
        await _api.get(ApiEndpoints.childDetails(childId))
            as Map<String, dynamic>;
    return ChildDetailsModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<LinkChildResultEntity> linkChild(LinkChildRequestModel request) async {
    // { "status": "success", "code": "child_linked",
    //   "data": { "result": "linked", "child": {...} } }
    // or "code": "link_request_submitted",
    //   "data": { "result": "pending_review", "request_id": 15 }
    final json =
        await _api.post(ApiEndpoints.linkChild, data: request.toJson())
            as Map<String, dynamic>;
    return LinkChildResultModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }
}
