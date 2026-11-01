import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/config/di/data_env.dart';
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_remote_data_source.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_info_model.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_message_model.dart';
import 'package:al_mahhaba_school/features/contact/data/static/static_contact_info.dart';

/// Stands in for the contact API with [staticContactInfo], while
/// `AppConfig.useStaticData` is on.
@LazySingleton(as: ContactRemoteDataSource, env: [DataEnv.staticData])
class ContactStaticDataSource implements ContactRemoteDataSource {
  @override
  Future<ContactInfoModel> getContactInfo() async => staticContactInfo;

  /// The contact form is hidden while the data is static.
  @override
  Future<void> sendMessage(ContactMessageModel message) =>
      throw UnsupportedError('Messages can only be sent through the API.');
}
