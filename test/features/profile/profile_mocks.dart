// The profile use cases, mocked once for the view model and page tests.
// Regenerate with `dart run build_runner build`.
// (mockito reads the annotation on an import, not on `library`.)
@GenerateNiceMocks([
  MockSpec<GetProfileUseCase>(),
  MockSpec<UpdateLanguageUseCase>(),
  MockSpec<DeleteAccountUseCase>(),
  MockSpec<GetNotificationPreferencesUseCase>(),
  MockSpec<UpdateNotificationPreferencesUseCase>(),
])
import 'package:mockito/annotations.dart';

import 'package:al_mahhaba_school/features/profile/domain/use_cases/delete_account_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_notification_preferences_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_language_use_case.dart';
import 'package:al_mahhaba_school/features/profile/domain/use_cases/update_notification_preferences_use_case.dart';
