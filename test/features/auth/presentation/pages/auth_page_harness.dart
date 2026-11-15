import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/stub_routes.dart';
import '../../../../helpers/test_app.dart';
import '../../auth_mocks.mocks.dart';

/// English, as the auth pages show it in the tests.
final l10n = lookupAppLocalizations(const Locale('en'));

/// Shows an auth page as the app does: its [AuthViewModel] is a real one
/// over the mocked use cases here, the app-wide parent, children and chat
/// badge view models are mocks, and the pages it opens are stand-ins
/// showing their path.
///
/// Create one in `setUp`, then [register]; `getIt.reset` in `tearDown`.
class AuthPageHarness {
  final checkPhone = MockCheckRegisterPhoneUseCase();
  final login = MockLoginUseCase();
  final sendOtp = MockSendOtpUseCase();
  final verifyOtp = MockVerifyOtpUseCase();
  final completeRegister = MockCompleteRegisterUseCase();
  final resetPassword = MockResetPasswordUseCase();
  final changePassword = MockChangePasswordUseCase();
  final logout = MockLogoutUseCase();
  final parentViewModel = MockParentViewModel();
  final childrenViewModel = MockChildrenViewModel();
  final chatUnreadViewModel = MockChatUnreadBloc();

  /// The `extra` each stand-in page was opened with, by path.
  final extras = <String, Object?>{};

  static const _stubs = [
    AppRoutes.explore,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.otp,
    AppRoutes.forgotPassword,
    AppRoutes.resetCode,
    AppRoutes.newPassword,
    AppRoutes.home,
    AppRoutes.settings,
  ];

  /// What the pages get from getIt.
  void register() {
    provideResultDummy<RegisterEligibilityEntity>();
    provideResultDummy<AuthSessionEntity>();
    provideResultDummy<PhoneVerificationEntity>();
    provideResultDummy<String>();
    provideResultDummy<void>();
    getIt
      ..registerFactory<AuthViewModel>(
        () => AuthViewModel(
          checkPhone,
          login,
          sendOtp,
          verifyOtp,
          completeRegister,
          resetPassword,
          changePassword,
        ),
      )
      ..registerSingleton<LogoutUseCase>(logout);
  }

  /// Opens [page] at [path], the first page (nothing to go back to).
  Future<void> pump(WidgetTester tester, String path, Widget page) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      initialLocation: path,
      routes: [
        GoRoute(path: path, builder: (_, _) => page),
        ...stubRoutes(_stubs.where((stub) => stub != path), extras: extras),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ParentViewModel>.value(value: parentViewModel),
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider<ChatUnreadBloc>.value(value: chatUnreadViewModel),
        ],
      ),
    );
    await tester.pump();
  }
}
