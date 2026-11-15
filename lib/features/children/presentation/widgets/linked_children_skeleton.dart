import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/features/children/presentation/widgets/linked_child_card_skeleton.dart';

/// [LinkedChildrenList]'s place while the children load: two card shapes.
class LinkedChildrenSkeleton extends StatelessWidget {
  const LinkedChildrenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: const [LinkedChildCardSkeleton(), LinkedChildCardSkeleton()],
    );
  }
}
