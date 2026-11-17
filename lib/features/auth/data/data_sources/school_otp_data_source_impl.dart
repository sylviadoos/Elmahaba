import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/network/api_endpoints.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/network/api_names.dart';
import 'package:al_mahhaba_school/core/network/api_service.dart';
import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/school_otp_data_source.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

@LazySingleton(as: SchoolOtpDataSource)
class SchoolOtpDataSourceImpl implements SchoolOtpDataSource {
  SchoolOtpDataSourceImpl(@Named(ApiNames.school) this._api);

  final ApiService _api;

  /// The school's own wait between codes, when it doesn't say.
  static const Duration defaultResendAfter = Duration(seconds: 60);

  @override
  Future<SchoolCodeSent> sendCode(String phone) async {
    // { "status": "success", "code": "otp_sent",
    //   "data": { "expires_in": 300, "resend_after": 60, "resends_left": 3,
    //             "phone_masked": "0101****222" } }
    final json =
        await _api.post(ApiEndpoints.otpRequest, data: {'phone': phone})
            as Map<String, dynamic>;
    final data = json[ApiKeys.data];
    final seconds = data is Map<String, dynamic>
        ? jsonDouble(data['resend_after'])?.toInt()
        : null;
    return SchoolCodeSent(
      resendAfter: seconds == null
          ? defaultResendAfter
          : Duration(seconds: seconds),
    );
  }
}
