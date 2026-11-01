import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/error/dio_exception_handler.dart';

/// The one place every HTTP call in the app goes through.
///
/// Each method returns the decoded response body (`Map` / `List`) and
/// throws an `AppException` on failure. Paths come from `ApiEndpoints`.
///
/// ```dart
/// final json = await apiService.post(ApiEndpoints.signin, data: body);
/// return User.fromJson(json);
/// ```
@lazySingleton
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

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
