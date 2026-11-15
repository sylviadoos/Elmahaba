import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/config/app_config.dart';

/// Around the whole app: records it (see `SessionRecorder`) with
/// everything masked, so what's on screen stays private — children's
/// names, grades, fees, messages, medical documents, what's typed. The
/// dashboard sees taps, scrolls and the layout only; `PublicContent`
/// shows the screens anyone may see. Just [app] while recording is off.
class SessionRecording extends StatelessWidget {
  const SessionRecording({super.key, required this.app});

  final Widget app;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.clarityEnabled) return app;

    return ClarityWidget(
      clarityConfig: ClarityConfig(
        projectId: AppConfig.clarityProjectId,
        // Tried in a debug build: its logs (tagged [Clarity]) say whether
        // it started. Release builds log nothing anyway.
        logLevel: kDebugMode ? LogLevel.Verbose : LogLevel.None,
      ),
      app: ClarityMask(child: app),
    );
  }
}
