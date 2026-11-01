import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Centered loading indicator.
///
/// Pass a [lottieAsset] (e.g. `AppLottie.loading`) to show an animation
/// instead of the default spinner.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.lottieAsset, this.size = 120});

  final String? lottieAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: lottieAsset == null
          ? const CircularProgressIndicator()
          : Lottie.asset(lottieAsset!, width: size, height: size),
    );
  }
}
