import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/repos/contact_repo.dart';

/// Sends a visitor's message: `final result = await sendMessage(message);`
@lazySingleton
class SendContactMessageUseCase {
  SendContactMessageUseCase(this._repo);

  final ContactRepo _repo;

  Future<Result<void>> call(ContactMessageEntity message) =>
      _repo.sendMessage(message);
}
