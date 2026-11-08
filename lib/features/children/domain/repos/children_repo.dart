import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class ChildrenRepo {
  /// The children saved on the phone (from log in, or the last
  /// [getChildren]); empty when none are. No API call.
  Future<List<ChildEntity>> getSavedChildren();

  /// The children on the parent's account, from the API — and saved.
  Future<Result<List<ChildEntity>>> getChildren();

  /// Everything the school has on the child [childId] (`studentId`).
  Future<Result<ChildDetailsEntity>> getChildDetails(int childId);

  /// Links a child by national ID — now, or once the school confirms it. A
  /// linked child is added to the saved ones.
  Future<Result<LinkChildResultEntity>> linkChild(
    LinkChildRequestEntity request,
  );
}
