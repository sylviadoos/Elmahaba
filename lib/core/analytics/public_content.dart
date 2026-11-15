import 'package:al_mahhaba_school/core/analytics/clarity.dart';
import 'package:flutter/widgets.dart';

/// What anyone may see (the school's own pages: Explore, News…), shown as
/// it is in session recordings; everything else is masked (see
/// `SessionRecording`). Never around a form or a parent's data.
class PublicContent extends StatelessWidget {
  const PublicContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ClarityUnmask(child: child);
}
