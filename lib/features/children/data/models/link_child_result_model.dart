import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_child_result_entity.dart';

/// Reads the `data` of `POST v1/parent/children/link` (and of
/// `…/link/verify-otp`) by its `result`.
abstract final class LinkChildResultModel {
  static LinkChildResultEntity fromJson(Map<String, dynamic> json) =>
      switch (json['result']) {
        // { "result": "linked", "child": {...} }
        'linked' => ChildLinked(
          ChildModel.fromJson(json['child'] as Map<String, dynamic>),
        ),
        // { "result": "otp_required", "verification": {...} }
        'otp_required' => ChildLinkCodeSent(
          LinkVerificationModel.fromJson(
            json['verification'] as Map<String, dynamic>,
          ),
        ),
        // { "result": "pending_review", "request_id": 15 }
        'pending_review' => ChildLinkPending(json['request_id'] as int),
        final result => throw FormatException('Unknown link result: $result'),
      };
}
