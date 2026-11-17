import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_request_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

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

  /// Links the child [linkChild] asked a code for ([ChildLinkCodeSent]),
  /// with its [proof]: the school's code as the parent entered it, or
  /// Firebase's sign-in to the school's number for the child. The child is
  /// added to the saved ones.
  Future<Result<ChildEntity>> verifyChildLink({
    required String token,
    required PhoneProofEntity proof,
  });

  /// Has Firebase send the code to [phone], the school's number for the
  /// child (`LinkVerificationEntity.phone`) — again, when given the last
  /// [resendToken]. Some Android phones verify the number without a code
  /// (`PhoneAutoVerified`). When it fails, [resendChildLinkCode] has the
  /// school text it instead.
  Future<Result<PhoneVerificationEntity>> sendChildLinkCode(
    String phone, {
    int? resendToken,
  });

  /// Has the school text the code of the check [token] — again, or
  /// instead of Firebase. The result is the same check, with how many more
  /// codes it can text.
  Future<Result<LinkVerificationEntity>> resendChildLinkCode(String token);
}
