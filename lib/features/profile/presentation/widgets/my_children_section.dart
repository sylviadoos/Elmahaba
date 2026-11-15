import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/add_child_button.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/profile_child_row.dart';

/// "My children" and one row each, which opens their details, then "Add a
/// child". On Settings, where the parent reaches them without opening
/// their own profile first.
class MyChildrenSection extends StatelessWidget {
  const MyChildrenSection({super.key});

  @override
  Widget build(BuildContext context) {
    final children = context.watchChildren();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        SectionTitle(context.l10n.myChildren),
        for (final child in children)
          ProfileChildRow(key: ValueKey(child.studentId), child),
        const AddChildButton(),
      ],
    );
  }
}
