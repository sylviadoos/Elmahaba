import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_remote_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_child_request_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart';

@LazySingleton(as: ChildrenRepo)
class ChildrenRepoImpl implements ChildrenRepo {
  ChildrenRepoImpl(this._remoteDataSource, this._localDataSource);

  final ChildrenRemoteDataSource _remoteDataSource;
  final ChildrenLocalDataSource _localDataSource;

  @override
  Future<List<ChildEntity>> getSavedChildren() =>
      _localDataSource.getSavedChildren();

  @override
  Future<Result<List<ChildEntity>>> getChildren() => Result.guard(() async {
    final children = await _remoteDataSource.getChildren();
    await _localDataSource.saveChildren(children);
    return children;
  });

  @override
  Future<Result<ChildDetailsEntity>> getChildDetails(int childId) =>
      Result.guard(() => _remoteDataSource.getChildDetails(childId));

  @override
  Future<Result<LinkChildResultEntity>> linkChild(
    LinkChildRequestEntity request,
  ) => Result.guard(() async {
    final result = await _remoteDataSource.linkChild(
      LinkChildRequestModel.fromEntity(request),
    );
    if (result case ChildLinked(:final child)) await _save(child);
    return result;
  });

  @override
  Future<Result<ChildEntity>> verifyChildLink({
    required String token,
    required String code,
  }) => Result.guard(() async {
    final child = await _remoteDataSource.verifyChildLink(
      token: token,
      code: code,
    );
    await _save(child);
    return child;
  });

  @override
  Future<Result<LinkVerificationEntity>> resendChildLinkCode(String token) =>
      Result.guard(() => _remoteDataSource.resendChildLinkCode(token));

  /// A child just linked joins the saved ones (in place, if it was there).
  Future<void> _save(ChildEntity child) async {
    final saved = await _localDataSource.getSavedChildren();
    await _localDataSource.saveChildren([
      for (final other in saved)
        if (other.studentId != child.studentId) other,
      child,
    ]);
  }
}
