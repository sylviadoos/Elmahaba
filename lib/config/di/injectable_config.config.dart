// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:al_mahhaba_school/config/di/register_module.dart' as _i1027;
import 'package:al_mahhaba_school/core/analytics/session_recorder.dart'
    as _i622;
import 'package:al_mahhaba_school/core/analytics/session_recorder_impl.dart'
    as _i194;
import 'package:al_mahhaba_school/core/app_settings/locale_theme_cubit.dart'
    as _i439;
import 'package:al_mahhaba_school/core/network/api_service.dart' as _i438;
import 'package:al_mahhaba_school/core/network/auth_interceptor.dart' as _i575;
import 'package:al_mahhaba_school/core/network/language_interceptor.dart'
    as _i133;
import 'package:al_mahhaba_school/core/notifications/notification_service.dart'
    as _i614;
import 'package:al_mahhaba_school/core/notifications/notification_service_impl.dart'
    as _i281;
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart' as _i480;
import 'package:al_mahhaba_school/core/pdf/pdf_previewer_impl.dart' as _i190;
import 'package:al_mahhaba_school/core/storage/secure_storage.dart' as _i9;
import 'package:al_mahhaba_school/core/storage/shared_pref_helper.dart'
    as _i833;
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source.dart'
    as _i647;
import 'package:al_mahhaba_school/features/announcements/data/data_sources/announcements_remote_data_source_impl.dart'
    as _i316;
import 'package:al_mahhaba_school/features/announcements/data/repos/announcements_repo_impl.dart'
    as _i782;
import 'package:al_mahhaba_school/features/announcements/domain/repos/announcements_repo.dart'
    as _i58;
import 'package:al_mahhaba_school/features/announcements/domain/use_cases/get_announcements_use_case.dart'
    as _i374;
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart'
    as _i341;
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source.dart'
    as _i640;
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_remote_data_source_impl.dart'
    as _i65;
import 'package:al_mahhaba_school/features/app_status/data/data_sources/app_status_static_data_source.dart'
    as _i35;
import 'package:al_mahhaba_school/features/app_status/data/repos/app_status_repo_impl.dart'
    as _i2;
import 'package:al_mahhaba_school/features/app_status/domain/repos/app_status_repo.dart'
    as _i443;
import 'package:al_mahhaba_school/features/app_status/domain/use_cases/get_app_status_use_case.dart'
    as _i23;
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_bloc.dart'
    as _i437;
import 'package:al_mahhaba_school/features/attendance/data/data_sources/attendance_remote_data_source.dart'
    as _i257;
import 'package:al_mahhaba_school/features/attendance/data/data_sources/attendance_remote_data_source_impl.dart'
    as _i110;
import 'package:al_mahhaba_school/features/attendance/data/repos/attendance_repo_impl.dart'
    as _i456;
import 'package:al_mahhaba_school/features/attendance/domain/repos/attendance_repo.dart'
    as _i810;
import 'package:al_mahhaba_school/features/attendance/domain/use_cases/get_month_attendance_use_case.dart'
    as _i1066;
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_view_model.dart'
    as _i735;
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source.dart'
    as _i682;
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source_impl.dart'
    as _i603;
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i55;
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source_impl.dart'
    as _i800;
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source.dart'
    as _i1016;
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source_impl.dart'
    as _i988;
import 'package:al_mahhaba_school/features/auth/data/repos/auth_repo_impl.dart'
    as _i1022;
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart'
    as _i947;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/change_password_use_case.dart'
    as _i583;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_register_phone_use_case.dart'
    as _i378;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_session_use_case.dart'
    as _i1070;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/complete_register_use_case.dart'
    as _i967;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/get_saved_parent_use_case.dart'
    as _i658;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/login_use_case.dart'
    as _i558;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/logout_use_case.dart'
    as _i76;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/reset_password_use_case.dart'
    as _i172;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/send_otp_use_case.dart'
    as _i668;
import 'package:al_mahhaba_school/features/auth/domain/use_cases/verify_otp_use_case.dart'
    as _i520;
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart'
    as _i889;
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart'
    as _i716;
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart'
    as _i694;
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source_impl.dart'
    as _i33;
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source.dart'
    as _i355;
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source_impl.dart'
    as _i693;
import 'package:al_mahhaba_school/features/chat/data/repos/chat_repo_impl.dart'
    as _i446;
import 'package:al_mahhaba_school/features/chat/domain/repos/chat_repo.dart'
    as _i619;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart'
    as _i778;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_cached_chat_use_case.dart'
    as _i99;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_unread_count_use_case.dart'
    as _i454;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_use_case.dart'
    as _i1029;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart'
    as _i25;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart'
    as _i165;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/send_chat_message_use_case.dart'
    as _i179;
import 'package:al_mahhaba_school/features/chat/domain/use_cases/watch_chat_reads_use_case.dart'
    as _i818;
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_bloc.dart'
    as _i924;
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart'
    as _i530;
import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart'
    as _i1049;
import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source_impl.dart'
    as _i275;
import 'package:al_mahhaba_school/features/children/data/data_sources/children_remote_data_source.dart'
    as _i279;
import 'package:al_mahhaba_school/features/children/data/data_sources/children_remote_data_source_impl.dart'
    as _i368;
import 'package:al_mahhaba_school/features/children/data/repos/children_repo_impl.dart'
    as _i850;
import 'package:al_mahhaba_school/features/children/domain/repos/children_repo.dart'
    as _i668;
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_child_details_use_case.dart'
    as _i378;
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_children_use_case.dart'
    as _i760;
import 'package:al_mahhaba_school/features/children/domain/use_cases/get_saved_children_use_case.dart'
    as _i449;
import 'package:al_mahhaba_school/features/children/domain/use_cases/link_child_use_case.dart'
    as _i528;
import 'package:al_mahhaba_school/features/children/domain/use_cases/resend_child_link_code_use_case.dart'
    as _i225;
import 'package:al_mahhaba_school/features/children/domain/use_cases/verify_child_link_use_case.dart'
    as _i1004;
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_view_model.dart'
    as _i567;
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart'
    as _i875;
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_view_model.dart'
    as _i960;
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source.dart'
    as _i663;
import 'package:al_mahhaba_school/features/complaints/data/data_sources/complaints_remote_data_source_impl.dart'
    as _i886;
import 'package:al_mahhaba_school/features/complaints/data/repos/complaints_repo_impl.dart'
    as _i469;
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart'
    as _i1051;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/download_complaint_attachment_use_case.dart'
    as _i503;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaint_categories_use_case.dart'
    as _i825;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaint_details_use_case.dart'
    as _i35;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/get_complaints_use_case.dart'
    as _i294;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/send_complaint_reply_use_case.dart'
    as _i1010;
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/send_complaint_use_case.dart'
    as _i383;
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/complaint_details_view_model.dart'
    as _i946;
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_view_model.dart'
    as _i669;
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/new_complaint_view_model.dart'
    as _i684;
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
import 'package:al_mahhaba_school/features/excuses/data/data_sources/excuses_remote_data_source.dart'
    as _i380;
import 'package:al_mahhaba_school/features/excuses/data/data_sources/excuses_remote_data_source_impl.dart'
    as _i859;
import 'package:al_mahhaba_school/features/excuses/data/repos/excuses_repo_impl.dart'
    as _i920;
import 'package:al_mahhaba_school/features/excuses/domain/repos/excuses_repo.dart'
    as _i1033;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/add_excuse_documents_use_case.dart'
    as _i608;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/download_excuse_document_use_case.dart'
    as _i626;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/get_excusable_absences_use_case.dart'
    as _i64;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/get_excuse_details_use_case.dart'
    as _i100;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/preview_excuse_document_use_case.dart'
    as _i435;
import 'package:al_mahhaba_school/features/excuses/domain/use_cases/submit_excuse_use_case.dart'
    as _i674;
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excusable_absences_view_model.dart'
    as _i569;
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excuse_details_view_model.dart'
    as _i691;
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/new_excuse_view_model.dart'
    as _i422;
import 'package:al_mahhaba_school/features/fees/data/data_sources/fees_remote_data_source.dart'
    as _i251;
import 'package:al_mahhaba_school/features/fees/data/data_sources/fees_remote_data_source_impl.dart'
    as _i840;
import 'package:al_mahhaba_school/features/fees/data/repos/fees_repo_impl.dart'
    as _i793;
import 'package:al_mahhaba_school/features/fees/domain/repos/fees_repo.dart'
    as _i990;
import 'package:al_mahhaba_school/features/fees/domain/use_cases/change_optional_fee_use_case.dart'
    as _i840;
import 'package:al_mahhaba_school/features/fees/domain/use_cases/get_fee_statement_use_case.dart'
    as _i337;
import 'package:al_mahhaba_school/features/fees/domain/use_cases/pay_online_use_case.dart'
    as _i261;
import 'package:al_mahhaba_school/features/fees/presentation/view_model/fees_view_model.dart'
    as _i740;
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_view_model.dart'
    as _i1065;
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source.dart'
    as _i503;
import 'package:al_mahhaba_school/features/home/data/data_sources/home_remote_data_source_impl.dart'
    as _i510;
import 'package:al_mahhaba_school/features/home/data/repos/home_repo_impl.dart'
    as _i524;
import 'package:al_mahhaba_school/features/home/domain/repos/home_repo.dart'
    as _i758;
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_child_dashboard_use_case.dart'
    as _i181;
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_new_messages_count_use_case.dart'
    as _i833;
import 'package:al_mahhaba_school/features/home/presentation/bloc/home_bloc.dart'
    as _i105;
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source.dart'
    as _i547;
import 'package:al_mahhaba_school/features/homework/data/data_sources/homework_remote_data_source_impl.dart'
    as _i303;
import 'package:al_mahhaba_school/features/homework/data/repos/homework_repo_impl.dart'
    as _i372;
import 'package:al_mahhaba_school/features/homework/domain/repos/homework_repo.dart'
    as _i243;
import 'package:al_mahhaba_school/features/homework/domain/use_cases/get_homework_use_case.dart'
    as _i417;
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart'
    as _i1002;
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source.dart'
    as _i816;
import 'package:al_mahhaba_school/features/news/data/data_sources/news_remote_data_source_impl.dart'
    as _i51;
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
import 'package:al_mahhaba_school/features/profile/data/data_sources/profile_remote_data_source.dart'
    as _i675;
import 'package:al_mahhaba_school/features/profile/data/data_sources/profile_remote_data_source_impl.dart'
    as _i613;
import 'package:al_mahhaba_school/features/profile/data/repos/profile_repo_impl.dart'
    as _i114;
import 'package:al_mahhaba_school/features/profile/domain/repos/profile_repo.dart'
    as _i559;
import 'package:al_mahhaba_school/features/profile/domain/use_cases/delete_account_use_case.dart'
    as _i9;
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_notification_preferences_use_case.dart'
    as _i228;
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_profile_use_case.dart'
    as _i884;
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_language_use_case.dart'
    as _i1010;
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_notification_preferences_use_case.dart'
    as _i317;
import 'package:al_mahhaba_school/features/profile/presentation/view_model/profile_view_model.dart'
    as _i322;
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source.dart'
    as _i459;
import 'package:al_mahhaba_school/features/results/data/data_sources/results_remote_data_source_impl.dart'
    as _i134;
import 'package:al_mahhaba_school/features/results/data/repos/results_repo_impl.dart'
    as _i60;
import 'package:al_mahhaba_school/features/results/domain/repos/results_repo.dart'
    as _i828;
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_results_use_case.dart'
    as _i218;
import 'package:al_mahhaba_school/features/results/domain/use_cases/mark_latest_result_read_use_case.dart'
    as _i515;
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart'
    as _i856;
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
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
    gh.lazySingleton<_i59.FirebaseAuth>(
      () => coreInjectableModule.firebaseAuth(),
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => coreInjectableModule.firebaseMessaging(),
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => coreInjectableModule.localNotifications(),
    );
    gh.lazySingleton<_i833.DeviceInfoPlugin>(
      () => coreInjectableModule.deviceInfo(),
    );
    gh.lazySingleton<_i833.SharedPrefHelper>(
      () => _i833.SharedPrefHelper(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i622.SessionRecorder>(() => _i194.SessionRecorderImpl());
    gh.lazySingleton<_i438.ApiService>(
      () => coreInjectableModule.signedFilesApi(),
      instanceName: 'signedFilesApi',
    );
    gh.lazySingleton<_i480.PdfPreviewer>(() => _i190.PdfPreviewerImpl());
    gh.lazySingleton<_i9.SecureStorage>(
      () => _i9.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i694.ChatLocalDataSource>(
      () => _i33.ChatLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i1049.ChildrenLocalDataSource>(
      () => _i275.ChildrenLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i439.LocaleThemeCubit>(
      () => _i439.LocaleThemeCubit(gh<_i833.SharedPrefHelper>()),
    );
    gh.singleton<_i575.AuthInterceptor>(
      () => _i575.AuthInterceptor(gh<_i9.SecureStorage>()),
    );
    gh.lazySingleton<_i1016.PhoneVerificationDataSource>(
      () => _i988.PhoneVerificationDataSourceImpl(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i236.ContactRemoteDataSource>(
      () => _i33.ContactStaticDataSource(),
      registerFor: {_static},
    );
    gh.lazySingleton<_i640.AppStatusRemoteDataSource>(
      () => _i35.AppStatusStaticDataSource(),
      registerFor: {_static},
    );
    gh.singleton<_i133.LanguageInterceptor>(
      () => _i133.LanguageInterceptor(gh<_i833.SharedPrefHelper>()),
    );
    gh.lazySingleton<_i614.NotificationService>(
      () => _i281.NotificationServiceImpl(
        gh<_i892.FirebaseMessaging>(),
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.lazySingleton<_i682.AuthLocalDataSource>(
      () => _i603.AuthLocalDataSourceImpl(
        gh<_i9.SecureStorage>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i833.SharedPrefHelper>(),
        gh<_i833.DeviceInfoPlugin>(),
        gh<_i614.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i438.ApiService>(
      () => coreInjectableModule.websiteApi(gh<_i133.LanguageInterceptor>()),
      instanceName: 'websiteApi',
    );
    gh.lazySingleton<_i438.ApiService>(
      () => coreInjectableModule.schoolApi(
        gh<_i575.AuthInterceptor>(),
        gh<_i133.LanguageInterceptor>(),
      ),
      instanceName: 'schoolApi',
    );
    gh.lazySingleton<_i55.AuthRemoteDataSource>(
      () => _i800.AuthRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i459.ResultsRemoteDataSource>(
      () => _i134.ResultsRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i257.AttendanceRemoteDataSource>(
      () => _i110.AttendanceRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i663.ComplaintsRemoteDataSource>(
      () => _i886.ComplaintsRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i236.ContactRemoteDataSource>(
      () => _i412.ContactRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'websiteApi'),
      ),
      registerFor: {_api},
    );
    gh.lazySingleton<_i675.ProfileRemoteDataSource>(
      () => _i613.ProfileRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i828.ResultsRepo>(
      () => _i60.ResultsRepoImpl(gh<_i459.ResultsRemoteDataSource>()),
    );
    gh.lazySingleton<_i279.ChildrenRemoteDataSource>(
      () => _i368.ChildrenRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i82.ContactRepo>(
      () => _i398.ContactRepoImpl(gh<_i236.ContactRemoteDataSource>()),
    );
    gh.lazySingleton<_i547.HomeworkRemoteDataSource>(
      () => _i303.HomeworkRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i559.ProfileRepo>(
      () => _i114.ProfileRepoImpl(gh<_i675.ProfileRemoteDataSource>()),
    );
    gh.lazySingleton<_i243.HomeworkRepo>(
      () => _i372.HomeworkRepoImpl(gh<_i547.HomeworkRemoteDataSource>()),
    );
    gh.lazySingleton<_i251.FeesRemoteDataSource>(
      () => _i840.FeesRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i1051.ComplaintsRepo>(
      () => _i469.ComplaintsRepoImpl(gh<_i663.ComplaintsRemoteDataSource>()),
    );
    gh.lazySingleton<_i947.AuthRepo>(
      () => _i1022.AuthRepoImpl(
        gh<_i55.AuthRemoteDataSource>(),
        gh<_i682.AuthLocalDataSource>(),
        gh<_i1016.PhoneVerificationDataSource>(),
        gh<_i1049.ChildrenLocalDataSource>(),
        gh<_i694.ChatLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i647.AnnouncementsRemoteDataSource>(
      () => _i316.AnnouncementsRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i990.FeesRepo>(
      () => _i793.FeesRepoImpl(gh<_i251.FeesRemoteDataSource>()),
    );
    gh.lazySingleton<_i668.ChildrenRepo>(
      () => _i850.ChildrenRepoImpl(
        gh<_i279.ChildrenRemoteDataSource>(),
        gh<_i1049.ChildrenLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i503.HomeRemoteDataSource>(
      () => _i510.HomeRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
    );
    gh.lazySingleton<_i218.GetResultsUseCase>(
      () => _i218.GetResultsUseCase(gh<_i828.ResultsRepo>()),
    );
    gh.lazySingleton<_i816.NewsRemoteDataSource>(
      () => _i51.NewsRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'websiteApi'),
      ),
    );
    gh.lazySingleton<_i810.AttendanceRepo>(
      () => _i456.AttendanceRepoImpl(gh<_i257.AttendanceRemoteDataSource>()),
    );
    gh.lazySingleton<_i758.HomeRepo>(
      () => _i524.HomeRepoImpl(gh<_i503.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i355.ChatRemoteDataSource>(
      () => _i693.ChatRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
        gh<_i438.ApiService>(instanceName: 'signedFilesApi'),
      ),
    );
    gh.lazySingleton<_i9.DeleteAccountUseCase>(
      () => _i9.DeleteAccountUseCase(gh<_i559.ProfileRepo>()),
    );
    gh.lazySingleton<_i228.GetNotificationPreferencesUseCase>(
      () => _i228.GetNotificationPreferencesUseCase(gh<_i559.ProfileRepo>()),
    );
    gh.lazySingleton<_i884.GetProfileUseCase>(
      () => _i884.GetProfileUseCase(gh<_i559.ProfileRepo>()),
    );
    gh.lazySingleton<_i1010.UpdateLanguageUseCase>(
      () => _i1010.UpdateLanguageUseCase(gh<_i559.ProfileRepo>()),
    );
    gh.lazySingleton<_i317.UpdateNotificationPreferencesUseCase>(
      () => _i317.UpdateNotificationPreferencesUseCase(gh<_i559.ProfileRepo>()),
    );
    gh.lazySingleton<_i1024.NewsRepo>(
      () => _i718.NewsRepoImpl(gh<_i816.NewsRemoteDataSource>()),
    );
    gh.lazySingleton<_i640.AppStatusRemoteDataSource>(
      () => _i65.AppStatusRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
      ),
      registerFor: {_api},
    );
    gh.lazySingleton<_i503.DownloadComplaintAttachmentUseCase>(
      () =>
          _i503.DownloadComplaintAttachmentUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i825.GetComplaintCategoriesUseCase>(
      () => _i825.GetComplaintCategoriesUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i35.GetComplaintDetailsUseCase>(
      () => _i35.GetComplaintDetailsUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i294.GetComplaintsUseCase>(
      () => _i294.GetComplaintsUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i1010.SendComplaintReplyUseCase>(
      () => _i1010.SendComplaintReplyUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i383.SendComplaintUseCase>(
      () => _i383.SendComplaintUseCase(gh<_i1051.ComplaintsRepo>()),
    );
    gh.lazySingleton<_i398.GetNewsDetailsUseCase>(
      () => _i398.GetNewsDetailsUseCase(gh<_i1024.NewsRepo>()),
    );
    gh.lazySingleton<_i113.GetNewsUseCase>(
      () => _i113.GetNewsUseCase(gh<_i1024.NewsRepo>()),
    );
    gh.lazySingleton<_i378.GetChildDetailsUseCase>(
      () => _i378.GetChildDetailsUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i760.GetChildrenUseCase>(
      () => _i760.GetChildrenUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i449.GetSavedChildrenUseCase>(
      () => _i449.GetSavedChildrenUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i528.LinkChildUseCase>(
      () => _i528.LinkChildUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i225.ResendChildLinkCodeUseCase>(
      () => _i225.ResendChildLinkCodeUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i1004.VerifyChildLinkUseCase>(
      () => _i1004.VerifyChildLinkUseCase(gh<_i668.ChildrenRepo>()),
    );
    gh.lazySingleton<_i380.ExcusesRemoteDataSource>(
      () => _i859.ExcusesRemoteDataSourceImpl(
        gh<_i438.ApiService>(instanceName: 'schoolApi'),
        gh<_i438.ApiService>(instanceName: 'signedFilesApi'),
      ),
    );
    gh.lazySingleton<_i1066.GetMonthAttendanceUseCase>(
      () => _i1066.GetMonthAttendanceUseCase(gh<_i810.AttendanceRepo>()),
    );
    gh.factory<_i99.NewsDetailsViewModel>(
      () => _i99.NewsDetailsViewModel(gh<_i398.GetNewsDetailsUseCase>()),
    );
    gh.factory<_i946.ComplaintDetailsViewModel>(
      () => _i946.ComplaintDetailsViewModel(
        gh<_i35.GetComplaintDetailsUseCase>(),
        gh<_i1010.SendComplaintReplyUseCase>(),
        gh<_i503.DownloadComplaintAttachmentUseCase>(),
      ),
    );
    gh.lazySingleton<_i583.ChangePasswordUseCase>(
      () => _i583.ChangePasswordUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i378.CheckRegisterPhoneUseCase>(
      () => _i378.CheckRegisterPhoneUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i1070.CheckSessionUseCase>(
      () => _i1070.CheckSessionUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i967.CompleteRegisterUseCase>(
      () => _i967.CompleteRegisterUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i658.GetSavedParentUseCase>(
      () => _i658.GetSavedParentUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i558.LoginUseCase>(
      () => _i558.LoginUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i76.LogoutUseCase>(
      () => _i76.LogoutUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i172.ResetPasswordUseCase>(
      () => _i172.ResetPasswordUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i668.SendOtpUseCase>(
      () => _i668.SendOtpUseCase(gh<_i947.AuthRepo>()),
    );
    gh.lazySingleton<_i520.VerifyOtpUseCase>(
      () => _i520.VerifyOtpUseCase(gh<_i947.AuthRepo>()),
    );
    gh.factory<_i960.LinkChildCodeViewModel>(
      () => _i960.LinkChildCodeViewModel(
        gh<_i1004.VerifyChildLinkUseCase>(),
        gh<_i225.ResendChildLinkCodeUseCase>(),
      ),
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
    gh.factory<_i484.NewsViewModel>(
      () => _i484.NewsViewModel(gh<_i113.GetNewsUseCase>()),
    );
    gh.factory<_i889.AuthViewModel>(
      () => _i889.AuthViewModel(
        gh<_i378.CheckRegisterPhoneUseCase>(),
        gh<_i558.LoginUseCase>(),
        gh<_i668.SendOtpUseCase>(),
        gh<_i520.VerifyOtpUseCase>(),
        gh<_i967.CompleteRegisterUseCase>(),
        gh<_i172.ResetPasswordUseCase>(),
        gh<_i583.ChangePasswordUseCase>(),
      ),
    );
    gh.lazySingleton<_i58.AnnouncementsRepo>(
      () => _i782.AnnouncementsRepoImpl(
        gh<_i647.AnnouncementsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i840.ChangeOptionalFeeUseCase>(
      () => _i840.ChangeOptionalFeeUseCase(gh<_i990.FeesRepo>()),
    );
    gh.lazySingleton<_i337.GetFeeStatementUseCase>(
      () => _i337.GetFeeStatementUseCase(gh<_i990.FeesRepo>()),
    );
    gh.lazySingleton<_i261.PayOnlineUseCase>(
      () => _i261.PayOnlineUseCase(gh<_i990.FeesRepo>()),
    );
    gh.lazySingleton<_i619.ChatRepo>(
      () => _i446.ChatRepoImpl(
        gh<_i355.ChatRemoteDataSource>(),
        gh<_i694.ChatLocalDataSource>(),
        gh<_i480.PdfPreviewer>(),
      ),
    );
    gh.lazySingleton<_i417.GetHomeworkUseCase>(
      () => _i417.GetHomeworkUseCase(gh<_i243.HomeworkRepo>()),
    );
    gh.factory<_i322.ProfileViewModel>(
      () => _i322.ProfileViewModel(
        gh<_i884.GetProfileUseCase>(),
        gh<_i1010.UpdateLanguageUseCase>(),
        gh<_i9.DeleteAccountUseCase>(),
        gh<_i228.GetNotificationPreferencesUseCase>(),
        gh<_i317.UpdateNotificationPreferencesUseCase>(),
      ),
    );
    gh.factory<_i716.ParentViewModel>(
      () => _i716.ParentViewModel(gh<_i658.GetSavedParentUseCase>()),
    );
    gh.lazySingleton<_i443.AppStatusRepo>(
      () => _i2.AppStatusRepoImpl(gh<_i640.AppStatusRemoteDataSource>()),
    );
    gh.factory<_i567.ChildDetailsViewModel>(
      () => _i567.ChildDetailsViewModel(gh<_i378.GetChildDetailsUseCase>()),
    );
    gh.factory<_i669.MyComplaintsViewModel>(
      () => _i669.MyComplaintsViewModel(gh<_i294.GetComplaintsUseCase>()),
    );
    gh.factory<_i735.AttendanceViewModel>(
      () => _i735.AttendanceViewModel(gh<_i1066.GetMonthAttendanceUseCase>()),
    );
    gh.lazySingleton<_i181.GetChildDashboardUseCase>(
      () => _i181.GetChildDashboardUseCase(gh<_i758.HomeRepo>()),
    );
    gh.lazySingleton<_i833.GetNewMessagesCountUseCase>(
      () => _i833.GetNewMessagesCountUseCase(gh<_i758.HomeRepo>()),
    );
    gh.lazySingleton<_i1033.ExcusesRepo>(
      () => _i920.ExcusesRepoImpl(
        gh<_i380.ExcusesRemoteDataSource>(),
        gh<_i480.PdfPreviewer>(),
      ),
    );
    gh.lazySingleton<_i608.AddExcuseDocumentsUseCase>(
      () => _i608.AddExcuseDocumentsUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.lazySingleton<_i626.DownloadExcuseDocumentUseCase>(
      () => _i626.DownloadExcuseDocumentUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.lazySingleton<_i64.GetExcusableAbsencesUseCase>(
      () => _i64.GetExcusableAbsencesUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.lazySingleton<_i100.GetExcuseDetailsUseCase>(
      () => _i100.GetExcuseDetailsUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.lazySingleton<_i435.PreviewExcuseDocumentUseCase>(
      () => _i435.PreviewExcuseDocumentUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.lazySingleton<_i674.SubmitExcuseUseCase>(
      () => _i674.SubmitExcuseUseCase(gh<_i1033.ExcusesRepo>()),
    );
    gh.factory<_i684.NewComplaintViewModel>(
      () => _i684.NewComplaintViewModel(
        gh<_i825.GetComplaintCategoriesUseCase>(),
        gh<_i383.SendComplaintUseCase>(),
      ),
    );
    gh.factory<_i875.ChildrenViewModel>(
      () => _i875.ChildrenViewModel(
        gh<_i449.GetSavedChildrenUseCase>(),
        gh<_i760.GetChildrenUseCase>(),
        gh<_i528.LinkChildUseCase>(),
      ),
    );
    gh.factory<_i210.ContactViewModel>(
      () => _i210.ContactViewModel(gh<_i329.GetContactInfoUseCase>()),
    );
    gh.factory<_i422.NewExcuseViewModel>(
      () => _i422.NewExcuseViewModel(gh<_i674.SubmitExcuseUseCase>()),
    );
    gh.lazySingleton<_i515.MarkLatestResultReadUseCase>(
      () => _i515.MarkLatestResultReadUseCase(
        gh<_i758.HomeRepo>(),
        gh<_i619.ChatRepo>(),
      ),
    );
    gh.lazySingleton<_i778.DownloadChatAttachmentUseCase>(
      () => _i778.DownloadChatAttachmentUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i99.GetCachedChatUseCase>(
      () => _i99.GetCachedChatUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i454.GetChatUnreadCountUseCase>(
      () => _i454.GetChatUnreadCountUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i1029.GetChatUseCase>(
      () => _i1029.GetChatUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i25.MarkChatReadUseCase>(
      () => _i25.MarkChatReadUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i165.PreviewChatAttachmentUseCase>(
      () => _i165.PreviewChatAttachmentUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i179.SendChatMessageUseCase>(
      () => _i179.SendChatMessageUseCase(gh<_i619.ChatRepo>()),
    );
    gh.lazySingleton<_i818.WatchChatReadsUseCase>(
      () => _i818.WatchChatReadsUseCase(gh<_i619.ChatRepo>()),
    );
    gh.factory<_i740.FeesViewModel>(
      () => _i740.FeesViewModel(
        gh<_i337.GetFeeStatementUseCase>(),
        gh<_i840.ChangeOptionalFeeUseCase>(),
      ),
    );
    gh.factory<_i856.ResultsViewModel>(
      () => _i856.ResultsViewModel(
        gh<_i218.GetResultsUseCase>(),
        gh<_i515.MarkLatestResultReadUseCase>(),
      ),
    );
    gh.lazySingleton<_i374.GetAnnouncementsUseCase>(
      () => _i374.GetAnnouncementsUseCase(gh<_i58.AnnouncementsRepo>()),
    );
    gh.factory<_i1065.PayFeesViewModel>(
      () => _i1065.PayFeesViewModel(gh<_i261.PayOnlineUseCase>()),
    );
    gh.factory<_i105.HomeBloc>(
      () => _i105.HomeBloc(
        gh<_i181.GetChildDashboardUseCase>(),
        gh<_i1066.GetMonthAttendanceUseCase>(),
        gh<_i818.WatchChatReadsUseCase>(),
      ),
    );
    gh.lazySingleton<_i23.GetAppStatusUseCase>(
      () => _i23.GetAppStatusUseCase(gh<_i443.AppStatusRepo>()),
    );
    gh.factory<_i569.ExcusableAbsencesViewModel>(
      () => _i569.ExcusableAbsencesViewModel(
        gh<_i64.GetExcusableAbsencesUseCase>(),
      ),
    );
    gh.factory<_i691.ExcuseDetailsViewModel>(
      () => _i691.ExcuseDetailsViewModel(
        gh<_i100.GetExcuseDetailsUseCase>(),
        gh<_i608.AddExcuseDocumentsUseCase>(),
        gh<_i626.DownloadExcuseDocumentUseCase>(),
        gh<_i435.PreviewExcuseDocumentUseCase>(),
      ),
    );
    gh.factory<_i437.AppStatusBloc>(
      () => _i437.AppStatusBloc(gh<_i23.GetAppStatusUseCase>()),
    );
    gh.factory<_i341.AnnouncementsBloc>(
      () => _i341.AnnouncementsBloc(
        gh<_i374.GetAnnouncementsUseCase>(),
        gh<_i25.MarkChatReadUseCase>(),
        gh<_i778.DownloadChatAttachmentUseCase>(),
        gh<_i165.PreviewChatAttachmentUseCase>(),
      ),
    );
    gh.factory<_i1002.HomeworkBloc>(
      () => _i1002.HomeworkBloc(
        gh<_i417.GetHomeworkUseCase>(),
        gh<_i25.MarkChatReadUseCase>(),
        gh<_i778.DownloadChatAttachmentUseCase>(),
        gh<_i165.PreviewChatAttachmentUseCase>(),
      ),
    );
    gh.factory<_i530.ChatUnreadBloc>(
      () => _i530.ChatUnreadBloc(
        gh<_i833.GetNewMessagesCountUseCase>(),
        gh<_i818.WatchChatReadsUseCase>(),
      ),
    );
    gh.factory<_i924.ChatBloc>(
      () => _i924.ChatBloc(
        gh<_i1029.GetChatUseCase>(),
        gh<_i99.GetCachedChatUseCase>(),
        gh<_i179.SendChatMessageUseCase>(),
        gh<_i25.MarkChatReadUseCase>(),
        gh<_i778.DownloadChatAttachmentUseCase>(),
        gh<_i165.PreviewChatAttachmentUseCase>(),
      ),
    );
    return this;
  }
}

class _$CoreInjectableModule extends _i1027.CoreInjectableModule {}
