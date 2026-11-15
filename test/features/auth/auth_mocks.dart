// The auth use cases and app-wide view models, mocked once for the view
// model and page tests. Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<CheckRegisterPhoneUseCase>(),
  MockSpec<LoginUseCase>(),
  MockSpec<SendOtpUseCase>(),
  MockSpec<VerifyOtpUseCase>(),
  MockSpec<CompleteRegisterUseCase>(),
  MockSpec<ResetPasswordUseCase>(),
  MockSpec<ChangePasswordUseCase>(),
  MockSpec<LogoutUseCase>(),
  MockSpec<GetSavedParentUseCase>(),
  MockSpec<ParentViewModel>(),
  MockSpec<ChildrenViewModel>(),
  MockSpec<ChatUnreadBloc>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/check_register_phone_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/complete_register_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/get_saved_parent_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/login_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/send_otp_use_case.dart';
import 'package:al_mahhaba_school/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_view_model.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
