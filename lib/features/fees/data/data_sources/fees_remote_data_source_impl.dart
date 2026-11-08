import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/fees/data/data_sources/fees_remote_data_source.dart';
import 'package:al_mahhaba_school/features/fees/data/models/checkout_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/fee_statement_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/pay_online_request_model.dart';

@LazySingleton(as: FeesRemoteDataSource)
class FeesRemoteDataSourceImpl implements FeesRemoteDataSource {
  FeesRemoteDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  @override
  Future<FeeStatementModel> getFeeStatement(int childId) async {
    // { "status": "success", "data": { "student": {…}, "fees": […],
    //   "payment_summary": {…}, "installments": […], … } }
    final json =
        await _api.get(ApiEndpoints.childFees(childId)) as Map<String, dynamic>;
    return FeeStatementModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<CheckoutModel> payOnline(
    int childId,
    PayOnlineRequestModel request,
  ) async {
    // { "status": "success", "data": { "checkout_url": "…",
    //   "checkout_session_id": "…", "items": […], "total": 5000 } }
    final json =
        await _api.post(
              ApiEndpoints.childFeesPayOnline(childId),
              data: request.toJson(),
            )
            as Map<String, dynamic>;
    return CheckoutModel.fromJson(json[ApiKeys.data] as Map<String, dynamic>);
  }
}
