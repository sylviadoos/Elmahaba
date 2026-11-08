/// Names of the `ApiService`s in DI — one per server, and one for signed
/// file links.
///
/// ```dart
/// NewsRemoteDataSourceImpl(@Named(ApiNames.website) this._api);
/// ```
abstract final class ApiNames {
  /// The school website (`AppConfig.websiteBaseUrl`) — no auth token.
  static const String website = 'websiteApi';

  /// The school system (`AppConfig.schoolBaseUrl`) — sends the parent's token.
  static const String school = 'schoolApi';

  /// Signed links to files (the link itself grants access, for a while) —
  /// nothing added: no token, which must never leave for wherever the files
  /// are stored.
  static const String signedFiles = 'signedFilesApi';
}
