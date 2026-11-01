import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

/// Opens links in other apps: the dialer, the mail app, Maps, a browser.
///
/// ```dart
/// ExternalLinks.open(context, ExternalLinks.phone('01222254245'));
/// ```
abstract final class ExternalLinks {
  static Uri phone(String number) =>
      Uri(scheme: 'tel', path: number.replaceAll(' ', ''));

  static Uri email(String address) => Uri(scheme: 'mailto', path: address);

  static Uri web(String url) => Uri.parse(url);

  /// Shows a snackbar if no app on the phone can open [uri].
  static Future<void> open(BuildContext context, Uri uri) async {
    bool opened;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened && context.mounted) {
      context.showSnackBar(context.l10n.couldNotOpenLink, isError: true);
    }
  }
}
