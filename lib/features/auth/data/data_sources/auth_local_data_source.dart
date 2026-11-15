import 'package:al_mahhaba_school/features/auth/data/models/client_info_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/parent_entity.dart';

/// The auth data kept on the phone.
abstract interface class AuthLocalDataSource {
  /// Keeps the school API's token; it's sent with every request after.
  Future<void> saveToken(String accessToken);

  /// Whether a token is kept — the parent stays signed in across launches.
  Future<bool> hasToken();

  /// Forgets the token (log out).
  Future<void> clearToken();

  /// Keeps the signed-in parent, so pages show them without calling the
  /// API.
  Future<void> saveParent(ParentEntity parent);

  /// The parent kept by [saveParent]; null when none is.
  Future<ParentModel?> getSavedParent();

  /// Forgets the parent (log out).
  Future<void> clearParent();

  /// The app's language and the device, sent when signing in.
  Future<ClientInfoModel> clientInfo();
}
