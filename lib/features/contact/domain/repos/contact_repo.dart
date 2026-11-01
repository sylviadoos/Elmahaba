import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ContactRepo {
  Future<Result<ContactInfoEntity>> getContactInfo();

  Future<Result<void>> sendMessage(ContactMessageEntity message);
}
