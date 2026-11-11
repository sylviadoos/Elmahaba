import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

/// Each announcement's text direction, found once: it reads the whole text.
final Expando<TextDirection> _textDirections = Expando('announcementDirection');

extension AnnouncementDisplay on AnnouncementEntity {
  /// The direction its text is written in (it may not be the app's).
  TextDirection get textDirection =>
      _textDirections[this] ??= '$title $body'.textDirection;
}
