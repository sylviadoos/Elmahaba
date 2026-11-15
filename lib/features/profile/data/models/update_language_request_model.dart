/// The body of `PUT …/profile/language`.
class UpdateLanguageRequestModel {
  const UpdateLanguageRequestModel({required this.language});

  /// "en" or "ar".
  final String language;

  /// { "language": "ar" }
  Map<String, dynamic> toJson() => {'language': language};
}
