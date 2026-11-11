import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/segmented_control.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_bloc.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_intent.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/certificate_labels.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/certificate_download_button.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/final_result_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_info_card.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_subjects_section.dart';

/// The monthly results: a month at a time (picked above), shown like any
/// result — its totals and rank, then each subject's marks by part — and
/// the certificate of every month to download under them.
class MonthlyResultsView extends StatefulWidget {
  const MonthlyResultsView({super.key, required this.results});

  /// With at least one month.
  final MonthlyResultsEntity results;

  @override
  State<MonthlyResultsView> createState() => _MonthlyResultsViewState();
}

class _MonthlyResultsViewState extends State<MonthlyResultsView> {
  /// The subject shown open, by its section and its place in it; the first
  /// counted subject at first, and again for another month.
  (int, int)? _open = (0, 0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.watch<MonthlyResultsBloc>();
    final certificate = widget.results.certificate!;
    final months = certificate.months;
    final month = bloc.state.selectedMonth ?? months.last;
    final result = widget.results.resultOf(
      month,
      studentName: certificate.studentNameIn(context),
    );
    final sections = [
      (l10n.subjects, l10n.countedInFinalResult, result.subjectsIncluded),
      (
        l10n.otherSubjects,
        l10n.notCountedInFinalResult,
        result.subjectsNotIncluded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        if (months.length > 1)
          SegmentedControl(
            options: [
              for (final month in months) SegmentOption(month.label(context)),
            ],
            selected: months.indexOf(month),
            onSelected: (index) {
              setState(() => _open = (0, 0));
              bloc.add(SelectMonthIntent(months[index].key));
            },
          ),
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
        CertificateDownloadButton(certificate: certificate),
      ],
    );
  }
}
