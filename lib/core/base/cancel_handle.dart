import 'package:dio/dio.dart';

/// Stops a request no longer needed (the page closed, another child was
/// picked): hand it to the use case, then [cancel]. The request then fails
/// with a `CancelledException`, which no one needs to show.
class CancelHandle {
  /// What `ApiService` takes.
  final CancelToken token = CancelToken();

  bool get isCancelled => token.isCancelled;

  void cancel() {
    if (!token.isCancelled) token.cancel();
  }
}
