import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_child_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

extension ChatChildName on ChatChildEntity {
  /// The Arabic name in Arabic (when the school has one), else the English;
  /// first names only, as the child tabs show them.
  String firstName(BuildContext context) {
    final full =
        Localizations.localeOf(context).languageCode == AppConstants.arKey &&
            nameAr.isNotEmpty
        ? nameAr
        : name;
    return full.split(' ').first;
  }
}

extension ChatAudienceName on ChatAudienceEntity {
  /// The Arabic name in Arabic (when the school has one), else the English,
  /// e.g. "Class 4B"; "All parents" when the school names no one.
  String label(BuildContext context) {
    final named =
        Localizations.localeOf(context).languageCode == AppConstants.arKey &&
            nameAr.isNotEmpty
        ? nameAr
        : name;
    if (named.isNotEmpty) return named;
    return type == ChatAudienceType.all ? context.l10n.allParents : '';
  }
}

/// Made once per pattern and language: making one reads its pattern and
/// the language's symbols, too slow to do for every message drawn.
final Map<String, DateFormat> _dateFormats = {};

DateFormat _dateFormat(String pattern, String locale) => _dateFormats
    .putIfAbsent('$pattern|$locale', () => DateFormat(pattern, locale));

/// Each message's [ChatItemDisplay.textDirection], found once: it reads
/// the whole text.
final Expando<TextDirection> _textDirections = Expando('chatTextDirection');

extension ChatItemDisplay on ChatItemEntity {
  /// Its text's own direction (it may not be the app's language).
  TextDirection get textDirection =>
      _textDirections[this] ??= text.textDirection;

  /// Who it's for: the parents a general item went to ("Class 4B"; empty
  /// when the school doesn't say), or the children of a private one
  /// ("Omar", "Omar, Lina").
  String aboutLabel(BuildContext context) =>
      isGeneral ? audience?.label(context) ?? '' : childrenLabel(context);

  /// The children it's about: "Omar", "Omar, Lina".
  String childrenLabel(BuildContext context) => children
      .map((child) => child.firstName(context))
      .join(context.isRtl ? '، ' : ', ');

  /// e.g. "10:15".
  String timeLabel(BuildContext context) => sentAt == null
      ? ''
      : _dateFormat(
          'Hm',
          Localizations.localeOf(context).toString(),
        ).format(sentAt!);

  /// What it says, in a line: for the message a reply answers.
  String snippet(BuildContext context) {
    if (isDeleted) return context.l10n.deletedMessage;
    final title = this.title;
    if (title != null) return title;
    if (text.isNotEmpty) return text;
    return attachments.firstOrNull?.fileName ?? '';
  }
}

extension ChatDay on DateTime {
  /// "Today", "Yesterday", "Monday 2 Nov", or "2 Nov 2025" from another
  /// year.
  String chatDayLabel(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysAgo = today.difference(DateTime(year, month, day)).inDays;
    if (daysAgo == 0) return l10n.today;
    if (daysAgo == 1) return l10n.yesterday;
    return _dateFormat(
      year == now.year ? 'EEEE d MMM' : 'd MMM y',
      locale,
    ).format(this);
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension ChatScreenLabel on ChatScreen {
  /// The button that opens it, e.g. "View attendance".
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ChatScreen.attendance => l10n.viewAttendance,
      ChatScreen.results => l10n.viewResults,
      ChatScreen.fees => l10n.viewFees,
      ChatScreen.complaint => l10n.viewComplaint,
      ChatScreen.homework => l10n.viewHomework,
    };
  }
}
