import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/certificate_download_button.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/final_result_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_activities_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_info_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_subjects_section.dart';

/// One result in full: what it is, the final result, every subject's mark
/// — tap one for its parts — and the activities; under a month's, the
/// [certificate] to download.
///
/// Give it the result's id as its key: another result opens its first
/// subject again.
class ResultDetailsView extends StatefulWidget {
  const ResultDetailsView({super.key, required this.result, this.certificate});

  final ResultDetailsEntity result;

  /// null hides the download (a term's); so does one with no marks on it
  /// yet, which would save as a blank page.
  final MonthlyCertificateEntity? certificate;

  @override
  State<ResultDetailsView> createState() => _ResultDetailsViewState();
}

class _ResultDetailsViewState extends State<ResultDetailsView> {
  /// The subject shown open, by its section and its place in it; the first
  /// counted subject at first.
  (int, int)? _open = (0, 0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = widget.result;
    final certificate = widget.certificate;
    final sections = [
      (l10n.subjects, l10n.countedInFinalResult, result.subjectsIncluded),
      (
        l10n.otherSubjects,
        l10n.notCountedInFinalResult,
        result.subjectsNotIncluded,
      ),
      (l10n.highLevel, l10n.highLevelNote, result.highLevel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        ResultInfoCard(result: result),
        FinalResultCard(result: result),
        for (final (section, (title, note, subjects)) in sections.indexed)
          if (subjects.isNotEmpty)
            ResultSubjectsSection(
              title: title,
              note: note,
              subjects: subjects,
              usesColors: result.usesColors,
              openIndex: _open?.$1 == section ? _open?.$2 : null,
              // Tapping the open one closes it.
              onToggle: (index) => setState(
                () =>
                    _open = _open == (section, index) ? null : (section, index),
              ),
            ),
        if (result.activities.isNotEmpty)
          ResultActivitiesCard(activities: result.activities),
        if (certificate != null && certificate.hasMarks)
          CertificateDownloadButton(certificate: certificate),
      ],
    );
  }
}
