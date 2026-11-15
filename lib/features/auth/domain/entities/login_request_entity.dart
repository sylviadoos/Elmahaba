import 'package:equatable/equatable.dart';

/// What a parent fills in on the Log in page.
class LoginRequestEntity extends Equatable {
  const LoginRequestEntity({required this.phone, required this.password});

  /// Local Egyptian mobile, e.g. "01201234154".
  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone, password];
}
