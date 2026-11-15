import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_avatar.dart';

/// "All children": the first two children's initials overlapping, in a
/// square [size] across. Each keeps its colors, as in [ChildAvatar].
class AllChildrenAvatar extends StatelessWidget {
  const AllChildrenAvatar({
    super.key,
    required this.children,
    required this.size,
  });

  /// At least one.
  final List<ChildEntity> children;
  final double size;

  @override
  Widget build(BuildContext context) {
    // A white ring sets them apart.
    Widget avatar(int index) => Container(
      padding: EdgeInsets.all(1.5.r),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      // Small enough that the second leaves the first's initial clear.
      child: ChildAvatar(
        name: children[index].displayName(context),
        index: index,
        size: size * 0.6,
        fontSize: size * 0.26,
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          PositionedDirectional(top: 0, start: 0, child: avatar(0)),
          if (children.length > 1)
            PositionedDirectional(bottom: 0, end: 0, child: avatar(1)),
        ],
      ),
    );
  }
}
