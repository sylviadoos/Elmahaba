import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/extensions/log_out.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_details_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/child_display.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/child_details_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_details_header.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/child_info_section.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// One of the parent's children, as the school has them: student,
/// school, contact, father, mother and guardian. Opened from Profile.
class ChildDetailsPage extends StatelessWidget {
  const ChildDetailsPage({super.key, required this.childId, this.preview});

  /// The child's `studentId`.
  final int childId;

  /// The child from the list, for the header while the rest loads.
  final ChildEntity? preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ChildDetailsViewModel>()
            ..doAction(LoadChildDetailsEvent(childId)),
      child: _ChildDetailsView(childId: childId, preview: preview),
    );
  }
}

class _ChildDetailsView extends StatelessWidget {
  const _ChildDetailsView({required this.childId, this.preview});

  final int childId;
  final ChildEntity? preview;

  void _load(BuildContext context, {bool refresh = false}) => context
      .read<ChildDetailsViewModel>()
      .doAction(LoadChildDetailsEvent(childId, refresh: refresh));

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildDetailsViewModel, ChildDetailsState>(
      // Signed out meanwhile: back to Log in.
      listenWhen: (previous, current) =>
          previous.details.state != current.details.state &&
          current.details.exception is UnauthorizedException,
      listener: (context, state) {
        context.showSnackBar(
          state.details.exception!.localizedMessage(context),
          isError: true,
        );
        context.logOut();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: BlocBuilder<ChildDetailsViewModel, ChildDetailsState>(
            builder: (context, state) {
              final details = state.details.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChildDetailsHeader(child: details?.child ?? preview),
                  Expanded(
                    child: details == null
                        ? _loadingOrError(context, state)
                        : RefreshIndicator(
                            color: AppColors.mahabbahRed,
                            onRefresh: () async =>
                                _load(context, refresh: true),
                            child: _content(context, details),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _loadingOrError(BuildContext context, ChildDetailsState state) {
    final exception = state.details.exception;
    if (exception == null) return const AppLoading();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: StateMessage(
        icon: AppIcons.user,
        title: exception.localizedMessage(context),
        action: RetryOrLogInButton(
          exception: exception,
          onRetry: () => _load(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ChildDetailsEntity details) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    String? date(DateTime? date) =>
        date == null ? null : DateFormat('d MMM y', locale).format(date);
    final child = details.child;
    final age = details.age;

    List<ChildInfo> parent(ChildParentEntity? parent) => [
      ChildInfo(l10n.name, parent?.displayName(context)),
      ChildInfo(l10n.job, parent?.job),
      ChildInfo(l10n.education, parent?.education),
      ChildInfo(l10n.phone, parent?.phone, isLtr: true),
    ];

    final sections = <(String, List<ChildInfo>)>[
      (
        l10n.childStudentInfo,
        [
          ChildInfo(l10n.studentCode, details.studentCode, isLtr: true),
          ChildInfo(l10n.nationalId, child.nationalId, isLtr: true),
          ChildInfo(l10n.dateOfBirth, date(details.dateOfBirth)),
          ChildInfo(l10n.age, age == null ? null : l10n.yearsOld(age)),
          ChildInfo(l10n.gender, details.gender?.localized(context)),
          ChildInfo(l10n.religion, details.religion?.localized(context)),
          ChildInfo(l10n.nationality, details.nationality?.localized(context)),
        ],
      ),
      (
        l10n.childSchoolInfo,
        [
          ChildInfo(l10n.grade, child.grade),
          ChildInfo(l10n.schoolClass, child.className),
          ChildInfo(l10n.academicYear, child.academicYear, isLtr: true),
          ChildInfo(l10n.enrolledOn, date(details.enrolledAt)),
          ChildInfo(l10n.previousSchool, details.previousSchool),
        ],
      ),
      (
        l10n.childContactInfo,
        [
          ChildInfo(l10n.address, details.address),
          ChildInfo(l10n.homePhone, details.homePhone, isLtr: true),
          ChildInfo(l10n.email, details.email, isLtr: true),
        ],
      ),
      (l10n.father, parent(details.father)),
      (l10n.mother, parent(details.mother)),
      (l10n.guardian, [ChildInfo(l10n.name, details.guardianName)]),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20.w,
        4.h,
        20.w,
        math.max(40.h, MediaQuery.paddingOf(context).bottom + 16),
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.h,
          children: [
            for (final (title, infos) in sections)
              if (ChildInfoSection.anyIn(infos))
                ChildInfoSection(title: title, infos: infos),
          ],
        ),
      ],
    );
  }
}
