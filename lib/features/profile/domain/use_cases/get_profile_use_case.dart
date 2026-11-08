import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart';

/// The parent's account: `final result = await getProfile();`
@lazySingleton
class GetProfileUseCase {
  GetProfileUseCase(this._repo);

  final ProfileRepo _repo;

  Future<Result<ProfileEntity>> call() => _repo.getProfile();
}
