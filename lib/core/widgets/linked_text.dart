import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:al_mahhaba_school/core/utils/external_links.dart';

/// [text] with every web link in it (`https://…`, `http://…`, `www.…`)
/// underlined in [linkColor] and opened in the browser by a tap; the rest
/// as plain [style].
class LinkedText extends StatefulWidget {
  const LinkedText(
    this.text, {
    super.key,
    this.style,
    this.linkColor,
    this.textDirection,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;

  /// The links' color; [style]'s color when null.
  final Color? linkColor;
  final TextDirection? textDirection;
  final TextAlign? textAlign;

  /// A link, up to the first space; punctuation right after it (a full
  /// stop, an Arabic comma…) isn't part of it.
  static final RegExp _link = RegExp(
    r'(?:https?://|www\.)[^\s]+?(?=[.,;:!?،؛)\]}"]*(?:\s|$))',
    caseSensitive: false,
  );

  @override
  State<LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<LinkedText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TextSpan _link(String link) {
    final uri = ExternalLinks.web(
      link.toLowerCase().startsWith('www.') ? 'https://$link' : link,
    );
    final recognizer = TapGestureRecognizer()
      ..onTap = () => ExternalLinks.open(context, uri);
    _recognizers.add(recognizer);
    return TextSpan(
      text: link,
      recognizer: recognizer,
      style: TextStyle(
        color: widget.linkColor,
        decoration: TextDecoration.underline,
        decorationColor: widget.linkColor ?? widget.style?.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilt from the text each time: last build's taps go.
    _disposeRecognizers();
    final text = widget.text;
    final spans = <InlineSpan>[];
    var start = 0;
    for (final match in LinkedText._link.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(_link(match[0]!));
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
    );
  }
}
