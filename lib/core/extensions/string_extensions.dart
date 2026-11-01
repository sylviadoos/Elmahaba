import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Bidi;

extension StringTextDirection on String {
  /// RTL for mostly-Arabic text, otherwise LTR. For text from the API,
  /// which may not match the app's language.
  TextDirection get textDirection => Bidi.detectRtlDirectionality(this)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
