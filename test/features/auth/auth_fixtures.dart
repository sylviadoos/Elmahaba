import 'package:al_mahhaba_school/features/auth/data/models/auth_session_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_eligibility_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/change_password_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/login_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/reset_password_request_entity.dart';

/// Test data shared by the auth tests, shaped like the API's.

const phone = '01012345678';
const password = 'secret123';
const firebaseIdToken = 'firebase-id-token';

const parentJson = <String, dynamic>{
  'id': 7,
  'name': 'Mina Nagy',
  'phone': '0101****678',
  'language': 'en',
};

const childJson = <String, dynamic>{
  'student_id': 9,
  'name': 'Selena Mina',
  'name_ar': 'سيلينا مينا',
  'national_id': '••••0923',
  'relationship': 'father',
  'access': 'active',
  'read_only_until': null,
  'photo_url': null,
  'grade': 'Second Primary',
  'class': '2A',
  'academic_year': '2026-2027',
};

/// The `data` of log in and of completing sign-up.
const sessionJson = <String, dynamic>{
  'access_token': 'jwt-token',
  'token_type': 'bearer',
  'expires_in': 157680000,
  'parent': parentJson,
  'children': [childJson],
  'auto_linked': 1,
  'next_screen': 'home',
};

final parent = ParentModel.fromJson(parentJson);
final session = AuthSessionModel.fromJson(sessionJson);

const eligibility = RegisterEligibilityModel(
  phoneMasked: '0101****678',
  eligible: true,
  alreadyRegistered: false,
);

const client = ClientInfoModel(
  language: 'en',
  deviceName: 'samsung SM-A515F',
  platform: 'android',
);

const registerRequest = RegisterRequestEntity(
  phone: phone,
  password: password,
  passwordConfirmation: password,
);

const loginRequest = LoginRequestEntity(phone: phone, password: password);

const resetRequest = ResetPasswordRequestEntity(
  phone: phone,
  firebaseIdToken: firebaseIdToken,
  password: password,
  passwordConfirmation: password,
);

const changeRequest = ChangePasswordRequestEntity(
  currentPassword: 'old-pass1',
  password: password,
  passwordConfirmation: password,
);
