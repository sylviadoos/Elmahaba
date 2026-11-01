// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:al_mahhaba_school/config/di/register_module.dart' as _i1027;
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart'
    as _i439;
import 'package:al_mahhaba_school/core/network/api_service.dart' as _i438;
import 'package:al_mahhaba_school/core/network/auth_interceptor.dart' as _i575;
import 'package:al_mahhaba_school/core/network/language_interceptor.dart'
    as _i133;
import 'package:al_mahhaba_school/core/storage/secure_storage.dart' as _i9;
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart'
    as _i833;
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_remote_data_source.dart'
    as _i236;
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_remote_data_source_impl.dart'
    as _i412;
import 'package:al_mahhaba_school/features/contact/data/data_sources/contact_static_data_source.dart'
    as _i33;
import 'package:al_mahhaba_school/features/contact/data/repos/contact_repo_impl.dart'
    as _i398;
import 'package:al_mahhaba_school/features/contact/domain/repos/contact_repo.dart'
    as _i82;
import 'package:al_mahhaba_school/features/contact/domain/use_cases/get_contact_info_use_case.dart'
    as _i329;
import 'package:al_mahhaba_school/features/contact/domain/use_cases/send_contact_message_use_case.dart'
    as _i794;
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_message_view_model.dart'
    as _i796;
import 'package:al_mahhaba_school/features/contact/presentation/view_model/contact_view_model.dart'
    as _i210;
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source.dart'
    as _i816;
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source_impl.dart'
    as _i51;
import 'package:al_mahhaba_school/features/news/data/data_sources/news_static_data_source.dart'
    as _i546;
import 'package:al_mahhaba_school/features/news/data/repos/news_repo_impl.dart'
    as _i718;
import 'package:al_mahhaba_school/features/news/domain/repos/news_repo.dart'
    as _i1024;
import 'package:al_mahhaba_school/features/news/domain/use_cases/get_news_details_use_case.dart'
    as _i398;
import 'package:al_mahhaba_school/features/news/domain/use_cases/get_news_use_case.dart'
    as _i113;
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_details_view_model.dart'
    as _i99;
import 'package:al_mahhaba_school/features/news/presentation/view_model/news_view_model.dart'
    as _i484;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

const String _static = 'static';
const String _api = 'api';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreInjectableModule = _$CoreInjectableModule();
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => coreInjectableModule.prefs(),
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreInjectableModule.secureStorage(),
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => coreInjectableModule.internetConnection(),
    );
    gh.lazySingleton<_i833.SharedPrefHelper>(
      () => _i833.SharedPrefHelper(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i9.SecureStorage>(
      () => _i9.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i439.LocaleThemeCubit>(
      () => _i439.LocaleThemeCubit(gh<_i833.SharedPrefHelper>()),
    );
    gh.singleton<_i575.AuthInterceptor>(
      () => _i575.AuthInterceptor(gh<_i9.SecureStorage>()),
    );
    gh.lazySingleton<_i236.ContactRemoteDataSource>(
      () => _i33.ContactStaticDataSource(),
      registerFor: {_static},
    );
    gh.singleton<_i133.LanguageInterceptor>(
      () => _i133.LanguageInterceptor(gh<_i833.SharedPrefHelper>()),
    );
    gh.lazySingleton<_i816.NewsRemoteDataSource>(
      () => _i546.NewsStaticDataSource(),
      registerFor: {_static},
    );
    gh.lazySingleton<_i361.Dio>(
      () => coreInjectableModule.dio(
        gh<_i575.AuthInterceptor>(),
        gh<_i133.LanguageInterceptor>(),
      ),
    );
    gh.lazySingleton<_i438.ApiService>(() => _i438.ApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i816.NewsRemoteDataSource>(
      () => _i51.NewsRemoteDataSourceImpl(gh<_i438.ApiService>()),
      registerFor: {_api},
    );
    gh.lazySingleton<_i236.ContactRemoteDataSource>(
      () => _i412.ContactRemoteDataSourceImpl(gh<_i438.ApiService>()),
      registerFor: {_api},
    );
    gh.lazySingleton<_i1024.NewsRepo>(
      () => _i718.NewsRepoImpl(gh<_i816.NewsRemoteDataSource>()),
    );
    gh.lazySingleton<_i398.GetNewsDetailsUseCase>(
      () => _i398.GetNewsDetailsUseCase(gh<_i1024.NewsRepo>()),
    );
    gh.lazySingleton<_i113.GetNewsUseCase>(
      () => _i113.GetNewsUseCase(gh<_i1024.NewsRepo>()),
    );
    gh.factory<_i99.NewsDetailsViewModel>(
      () => _i99.NewsDetailsViewModel(gh<_i398.GetNewsDetailsUseCase>()),
    );
    gh.factory<_i484.NewsViewModel>(
      () => _i484.NewsViewModel(gh<_i113.GetNewsUseCase>()),
    );
    gh.lazySingleton<_i82.ContactRepo>(
      () => _i398.ContactRepoImpl(gh<_i236.ContactRemoteDataSource>()),
    );
    gh.lazySingleton<_i329.GetContactInfoUseCase>(
      () => _i329.GetContactInfoUseCase(gh<_i82.ContactRepo>()),
    );
    gh.lazySingleton<_i794.SendContactMessageUseCase>(
      () => _i794.SendContactMessageUseCase(gh<_i82.ContactRepo>()),
    );
    gh.factory<_i796.ContactMessageViewModel>(
      () =>
          _i796.ContactMessageViewModel(gh<_i794.SendContactMessageUseCase>()),
    );
    gh.factory<_i210.ContactViewModel>(
      () => _i210.ContactViewModel(gh<_i329.GetContactInfoUseCase>()),
    );
    return this;
  }
}

class _$CoreInjectableModule extends _i1027.CoreInjectableModule {}
