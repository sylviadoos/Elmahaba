import 'dart:io';

import 'package:dio/dio.dart';

import 'package:al_mahhaba_school/core/error/dio_exception_handler.dart';

/// The one place every HTTP call in the app goes through.
///
/// Each method returns the decoded response body (`Map` / `List`) and
/// throws an `AppException` on failure. Paths come from `ApiEndpoints`.
///
/// There is one per server (see `ApiNames`), registered in
/// `CoreInjectableModule` — ask for the one you need by name:
///
/// ```dart
/// MyRemoteDataSourceImpl(@Named(ApiNames.school) this._api);
///
/// final json = await _api.post(ApiEndpoints.login, data: body);
/// return User.fromJson(json);
/// ```
class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ),
  );

  /// Multipart upload (profile photo, homework file…).
  ///
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'file': await MultipartFile.fromFile(path),
  /// });
  /// await apiService.upload(ApiEndpoints.uploadPhoto, formData: formData);
  /// ```
  Future<dynamic> upload(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) => _request(
    () => _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    ),
  );

  /// Saves the file at [path] to [savePath] (an attachment…). Only a whole
  /// file is ever at [savePath]: it comes into a file of its own first and
  /// takes that name once it's all here. So the app closing halfway leaves
  /// nothing there that looks downloaded (the half is cleared with the
  /// temporary files), and two downloads of the same file at once don't
  /// write into one another.
  ///
  /// ```dart
  /// await apiService.download(
  ///   ApiEndpoints.complaintAttachment(complaintId, attachmentId),
  ///   file.path,
  /// );
  /// ```
  Future<void> download(
    String path,
    String savePath, {
    CancelToken? cancelToken,
  }) async {
    final part = '$savePath.${DateTime.now().microsecondsSinceEpoch}.part';
    // Dio deletes the part itself when the download fails or is cancelled.
    await _request(() => _dio.download(path, part, cancelToken: cancelToken));
    await File(part).rename(savePath);
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
