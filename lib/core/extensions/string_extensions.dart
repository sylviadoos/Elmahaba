import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Bidi;

extension StringTextDirection on String {
  /// RTL for mostly-Arabic text, otherwise LTR. For text from the API,
  /// which may not match the app's language.
  TextDirection get textDirection => Bidi.detectRtlDirectionality(this)
      ? TextDirection.rtl
      : TextDirection.ltr;

  /// Kept left to right inside Arabic text, e.g. a masked account number
  /// "*46******", which would otherwise come out "******46*".
  String get ltrIsolated => '\u2066$this\u2069';
}

extension NameInitials on String {
  /// The first letters of the first two names: "SA" for "Samar Ahmed".
  /// Arabic letters stay apart ("م ن", not the word "من"): a zero-width
  /// non-joiner goes between them.
  String get initials => split(' ')
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word.characters.first)
      .join('‌')
      .toUpperCase();
}

extension StringLocalPhone on String {
  /// A mobile typed after the +20 prefix, as the API wants it:
  /// "1012345678" or "01012345678" → "01012345678".
  String get localPhone {
    final digits = trim();
    if (digits.isEmpty || digits.startsWith('0')) return digits;
    return '0$digits';
  }
}
