/// Microsoft Clarity on the phone; on the web, the same names doing
/// nothing — its package (through `xxh3`) can't be built for the web.
library;

export 'clarity_web.dart'
    if (dart.library.io) 'package:clarity_flutter/clarity_flutter.dart';
