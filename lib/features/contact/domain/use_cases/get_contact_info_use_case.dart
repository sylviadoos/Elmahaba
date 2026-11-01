import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/repos/contact_repo.dart';

/// Loads the school's contact details: `final result = await getContactInfo();`
@lazySingleton
class GetContactInfoUseCase {
  GetContactInfoUseCase(this._repo);

  final ContactRepo _repo;

  Future<Result<ContactInfoEntity>> call() => _repo.getContactInfo();
}
