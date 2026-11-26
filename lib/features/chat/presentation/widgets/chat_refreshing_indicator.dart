import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The spinner under the newest item while the parent's pull for newer
/// ones is on its way (see `ChatPullToRefresh`).
class ChatRefreshingIndicator extends StatelessWidget {
  const ChatRefreshingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Center(
        child: SizedBox.square(
          dimension: 24.r,
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
