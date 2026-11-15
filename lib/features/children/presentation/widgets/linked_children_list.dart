import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/linked_child_card.dart';

/// The children on the account, one [LinkedChildCard] each.
class LinkedChildrenList extends StatelessWidget {
  const LinkedChildrenList({super.key, required this.children});

  final List<ChildEntity> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        for (final child in children)
          LinkedChildCard(key: ValueKey(child.studentId), child: child),
      ],
    );
  }
}
