import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A spinner at the end of a paged list that asks for the next page
/// ([onShown]) once the list builds it, i.e. scrolls near it.
///
/// Give it a key that changes with each page loaded, e.g.
/// `ValueKey(page)`, so it asks again for the one after.
class LoadMoreIndicator extends StatefulWidget {
  const LoadMoreIndicator({super.key, required this.onShown});

  final VoidCallback onShown;

  @override
  State<LoadMoreIndicator> createState() => _LoadMoreIndicatorState();
}

class _LoadMoreIndicatorState extends State<LoadMoreIndicator> {
  @override
  void initState() {
    super.initState();
    // After this frame: asking changes the state the list is built from.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onShown();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: SizedBox.square(
          dimension: 24.r,
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
