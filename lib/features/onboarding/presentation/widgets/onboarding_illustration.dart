import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Plays an onboarding Lottie: its "intro" part once each time the slide is
/// shown, then its "loop" part (a marker in the file) over and over.
/// Paused while the slide is off screen.
class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.asset,
    required this.isActive,
    required this.size,
  });

  final String asset;
  final bool isActive;
  final Size size;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  static const String _loopMarker = 'loop';

  late final AnimationController _controller = AnimationController(vsync: this);
  LottieComposition? _composition;

  @override
  void didUpdateWidget(covariant OnboardingIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      _play();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoaded(LottieComposition composition) {
    _composition = composition;
    _controller.duration = composition.duration;
    if (widget.isActive) _play();
  }

  Future<void> _play() async {
    final composition = _composition;
    if (composition == null) return;

    try {
      await _controller.forward(from: 0).orCancel;
    } on TickerCanceled {
      return; // Slide left (or disposed) before the intro finished.
    }

    final loop = composition.getMarker(_loopMarker);
    final loopStart = loop == null
        ? 0.0
        : (loop.startFrame - composition.startFrame) /
              composition.durationFrames;
    _controller.repeat(min: loopStart, max: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.asset,
      controller: _controller,
      onLoaded: _onLoaded,
      width: widget.size.width,
      height: widget.size.height,
      fit: BoxFit.contain,
    );
  }
}
