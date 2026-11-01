import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/network/api_keys.dart';
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart';

/// Tells the API which language the app is in (`Accept-Language: ar`),
/// read on every request so a language change applies right away.
@singleton
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._prefs);

  final SharedPrefHelper _prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[ApiKeys.acceptLanguage] =
        _prefs.getString(AppConstants.languageCode) ?? AppConstants.enKey;
    handler.next(options);
  }
}
