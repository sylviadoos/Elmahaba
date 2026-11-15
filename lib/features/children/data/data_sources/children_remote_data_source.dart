import 'package:al_mahhaba_school/features/children/data/models/child_details_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_child_request_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

/// Talks to the school system's children endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class ChildrenRemoteDataSource {
  /// The children linked to the parent's account.
  Future<List<ChildModel>> getChildren();

  /// Everything the school has on the child [childId] (`studentId`).
  Future<ChildDetailsModel> getChildDetails(int childId);

  /// Links a child to the parent's account by national ID: right away
  /// ([ChildLinked]), once the parent enters the code the school texted to
  /// the child's phone ([ChildLinkCodeSent]), or once the school confirms
  /// it ([ChildLinkPending]).
  ///
  /// Fails with a `ServerException` whose `code` says why — e.g.
  /// `child_already_linked`; invalid fields (422) are in `fieldErrors`.
  Future<LinkChildResultEntity> linkChild(LinkChildRequestModel request);

  /// Links the child the code of the check [token] was texted for. Fails
  /// with a `ServerException`: `otp_incorrect` (`attempts_left`),
  /// `otp_expired`, `link_verification_invalid`, `link_attempts_exceeded`
  /// or `child_already_linked`.
  Future<ChildModel> verifyChildLink({
    required String token,
    required String code,
  });

  /// Texts that code again. Fails with a `ServerException`:
  /// `otp_resend_too_soon` (`retry_after`), `otp_resend_limit` or
  /// `link_verification_invalid`.
  Future<LinkVerificationModel> resendChildLinkCode(String token);
}
