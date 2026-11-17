// The web's stand-in for `clarity_flutter`: only what the app uses, with
// its names, nothing recorded.
// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

enum LogLevel { Verbose, None }

class ClarityConfig {
  const ClarityConfig({required this.projectId, this.logLevel});

  final String projectId;
  final LogLevel? logLevel;
}

abstract final class Clarity {
  static bool setCustomUserId(String customUserId) => false;

  static bool startNewSession(void Function(String sessionId) callback) =>
      false;

  static bool setCurrentScreenName(String? screenName) => false;
}

class ClarityWidget extends StatelessWidget {
  const ClarityWidget({
    super.key,
    required this.app,
    required this.clarityConfig,
  });

  final Widget app;
  final ClarityConfig clarityConfig;

  @override
  Widget build(BuildContext context) => app;
}

class ClarityMask extends StatelessWidget {
  const ClarityMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class ClarityUnmask extends StatelessWidget {
  const ClarityUnmask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
