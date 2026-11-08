import 'package:al_mahhaba_school/features/auth/data/models/parent_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_model.dart';

/// [AuthSessionEntity] plus the token the API sends with it
/// (`"token_type": "bearer"`).
class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required this.accessToken,
    required this.expiresIn,
    required super.parent,
    required super.children,
    required super.autoLinked,
    required super.nextScreen,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json['access_token'] as String,
        expiresIn: Duration(seconds: json['expires_in'] as int),
        parent: ParentModel.fromJson(json['parent'] as Map<String, dynamic>),
        children: [
          for (final child in json['children'] as List<dynamic>? ?? const [])
            ChildModel.fromJson(child as Map<String, dynamic>),
        ],
        autoLinked: json['auto_linked'] as int? ?? 0,
        nextScreen: json['next_screen'] as String,
      );

  final String accessToken;

  /// How long [accessToken] works (about 5 years).
  final Duration expiresIn;

  @override
  List<Object?> get props => [...super.props, accessToken, expiresIn];
}
