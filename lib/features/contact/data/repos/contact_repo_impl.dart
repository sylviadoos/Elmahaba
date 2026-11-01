import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_remote_data_source.dart';
import 'package:al_mahhaba_school/features/contact/data/models/contact_message_model.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_info_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';
import 'package:al_mahhaba_school/features/contact/domain/repos/contact_repo.dart';

@LazySingleton(as: ContactRepo)
class ContactRepoImpl implements ContactRepo {
  ContactRepoImpl(this._remoteDataSource);

  final ContactRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ContactInfoEntity>> getContactInfo() =>
      Result.guard(_remoteDataSource.getContactInfo);

  @override
  Future<Result<void>> sendMessage(ContactMessageEntity message) =>
      Result.guard(
        () => _remoteDataSource.sendMessage(
          ContactMessageModel.fromEntity(message),
        ),
      );
}
