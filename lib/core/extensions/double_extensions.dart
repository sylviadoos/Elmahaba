extension OneDecimal on double {
  /// To one decimal, without a trailing ".0": "98.4", "100".
  String get oneDecimal {
    final rounded = (this * 10).round() / 10;
    return rounded == rounded.truncateToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
  }
}
