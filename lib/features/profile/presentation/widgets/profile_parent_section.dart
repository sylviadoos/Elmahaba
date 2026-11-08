import 'package:flutter/widgets.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_info_section.dart';

/// The children's father or mother on the parent's profile, as a child's
/// details show them: name, job, education and phone, the ones the school
/// has. "· You" in the [title] when it's the parent signed in.
class ProfileParentSection extends StatelessWidget {
  const ProfileParentSection({
    super.key,
    required this.title,
    required this.parent,
    this.isYou = false,
  });

  /// "Father" or "Mother".
  final String title;
  final ChildParentEntity parent;
  final bool isYou;

  /// The lines [parent] has; none means there's nothing to show.
  static List<ChildInfo> infosOf(
    BuildContext context,
    ChildParentEntity parent,
  ) {
    final l10n = context.l10n;
    return [
      ChildInfo(l10n.name, parent.displayName(context)),
      ChildInfo(l10n.job, parent.job),
      ChildInfo(l10n.education, parent.education),
      ChildInfo(l10n.phone, parent.phone, isLtr: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChildInfoSection(
      title: isYou ? '$title · ${context.l10n.you}' : title,
      infos: infosOf(context, parent),
    );
  }
}
