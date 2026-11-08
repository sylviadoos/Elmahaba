/// How far an upload got: [sent] of [total] bytes.
typedef UploadProgress = ({int sent, int total});

/// Called as an upload goes, with how much of it was sent.
typedef UploadProgressCallback = void Function(int sent, int total);

extension UploadProgressSteps on UploadProgress? {
  /// [sent] of [total] is worth showing: a percent more than this, or the
  /// end. Uploads report every few kilobytes, far more often than that.
  bool isStepTo(int sent, int total) {
    final shown = this;
    if (shown == null || sent >= total || total <= 0) return true;
    return (sent - shown.sent) * 100 >= total;
  }
}
