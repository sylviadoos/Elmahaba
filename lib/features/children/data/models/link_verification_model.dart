import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';

class LinkVerificationModel extends LinkVerificationEntity {
  const LinkVerificationModel({
    required super.token,
    required super.maskedPhone,
    required super.relationship,
    required super.expiresIn,
    required super.resendAfter,
    required super.resendsLeft,
    super.phone,
  });

  /// { "verification_token": "9b1f4c2e-…", "masked_phone": "••• ••• 4567",
  ///   "relationship": "father", "expires_in": 300, "resend_after": 60,
  ///   "resends_left": 3, "phone": "01012345678" } — times in seconds;
  ///   `phone` only when the school leaves sending the code to Firebase.
  factory LinkVerificationModel.fromJson(Map<String, dynamic> json) =>
      LinkVerificationModel(
        token: jsonText(json['verification_token']),
        maskedPhone: jsonText(json['masked_phone']),
        relationship: jsonText(json['relationship']),
        expiresIn: _seconds(json['expires_in']),
        resendAfter: _seconds(json['resend_after']),
        resendsLeft: jsonDouble(json['resends_left'])?.toInt() ?? 0,
        phone: jsonTextOrNull(json['phone']),
      );

  static Duration _seconds(Object? value) =>
      Duration(seconds: jsonDouble(value)?.toInt() ?? 0);
}
