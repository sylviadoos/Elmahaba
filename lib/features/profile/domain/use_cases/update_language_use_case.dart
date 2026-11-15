import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

/// Saves the account's language: `await updateLanguage('ar');`
@lazySingleton
class UpdateLanguageUseCase {
  UpdateLanguageUseCase(this._repo);

  final ProfileRepo _repo;

  Future<Result<void>> call(String language) => _repo.updateLanguage(language);
}
