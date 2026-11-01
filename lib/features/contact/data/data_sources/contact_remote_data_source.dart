import 'package:al_mahhaba_school/features/contact/data/models/contact_info_model.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_message_model.dart';

/// Talks to the school API's contact endpoints. Throws an `AppException`
/// on failure.
abstract interface class ContactRemoteDataSource {
  Future<ContactInfoModel> getContactInfo();

  /// Invalid fields fail with a 422 `ServerException` whose `fieldErrors`
  /// name them.
  Future<void> sendMessage(ContactMessageModel message);
}
