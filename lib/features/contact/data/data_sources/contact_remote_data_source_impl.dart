import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_remote_data_source.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_info_model.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_message_model.dart';

@LazySingleton(as: ContactRemoteDataSource, env: [DataEnv.api])
class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  ContactRemoteDataSourceImpl(@Named(ApiNames.website) this._api);

  final ApiService _api;

  @override
  Future<ContactInfoModel> getContactInfo() async {
    // { "status": "success", "data": { "address": "...", "phones": [...] } }
    final json = await _api.get(ApiEndpoints.contactUs) as Map<String, dynamic>;
    return ContactInfoModel.fromJson(
      json[ApiKeys.data] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> sendMessage(ContactMessageModel message) async {
    // { "status": "success", "code": "message_sent", "message": "Thank you!…" }
    await _api.post(ApiEndpoints.contactUsSend, data: message.toJson());
  }
}
