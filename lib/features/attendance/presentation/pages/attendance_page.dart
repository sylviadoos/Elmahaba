import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/page_refresher.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_event.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_state.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/view_model/attendance_view_model.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/attendance_count_tile.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/attendance_events_section.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/attendance_skeleton.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/attendance_summary_card.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_calendar.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_switcher.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/extensions/children_context.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/widgets/no_children_state.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_details_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excuse_rules_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/excuse_args.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_dates.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excusable_absences_event.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/view_model/excusable_absences_view_model.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// The selected child's attendance, a month at a time: the rate, the
/// counts, the calendar and the days that weren't plain school days — with
/// a medical excuse to send for an absence, or to follow.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AttendanceViewModel>()),
        BlocProvider(create: (_) => getIt<ExcusableAbsencesViewModel>()),
      ],
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatefulWidget {
  const _AttendanceView();

  @override
  State<_AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<_AttendanceView> {
  /// The month shown — this one at first; there's nothing after it.
  DateTime _month = _thisMonth();

  static DateTime _thisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  void initState() {
    super.initState();
    _loadChild();
  }

  /// The selected child's `studentId`; null without children.
  int? get _childId =>
      context.read<ChildrenViewModel>().state.selectedChild?.studentId;

  /// The selected child's attendance in [_month]; nothing to load without
  /// children.
  void _loadMonth() {
    final childId = _childId;
    if (childId == null) return;
    context.read<AttendanceViewModel>().doAction(
      LoadAttendanceEvent(childId: childId, month: _month),
    );
  }

  /// Which of the selected child's absences take an excuse.
  void _loadExcuses() {
    final childId = _childId;
    if (childId == null) return;
    context.read<ExcusableAbsencesViewModel>().doAction(
      LoadExcusableAbsencesEvent(childId),
    );
  }

  void _loadChild() {
    _loadMonth();
    _loadExcuses();
  }

  /// The month and the absences asked again, quietly: an excuse may have
  /// been accepted, attendance taken… (see [PageRefresher]).
  void _refresh() {
    context.read<AttendanceViewModel>().doAction(
      const RefreshAttendanceEvent(),
    );
    _loadExcuses();
  }

  /// Once sent, it opens. The page asks again on the way back from each
  /// ([PageRefresher]).
  Future<void> _submitExcuse(
    ExcusableAbsenceEntity absence,
    ExcuseRulesEntity rules,
  ) async {
    final childId = _childId;
    if (childId == null) return;
    final sent = await context.push<ExcuseDetailsEntity>(
      AppRoutes.newExcuse,
      extra: NewExcuseArgs(childId: childId, absence: absence, rules: rules),
    );
    if (!mounted || sent == null) return;
    await _openExcuse(sent.id, shown: sent, rules: rules);
  }

  /// Where it stands may change there (documents added): the page asks
  /// again on the way back ([PageRefresher]).
  Future<void> _openExcuse(
    int excuseId, {
    ExcuseDetailsEntity? shown,
    ExcuseRulesEntity? rules,
  }) async {
    final childId = _childId;
    if (childId == null) return;
    await context.push(
      AppRoutes.excuseDetailsOf(childId, excuseId),
      extra: ExcuseDetailsArgs(shown: shown, rules: rules),
    );
  }

  /// [step] months away: -1 back, 1 forward.
  void _moveMonth(int step) {
    setState(() => _month = DateTime(_month.year, _month.month + step));
    _loadMonth();
  }

  void _previousMonth() => _moveMonth(-1);

  /// Null on this month: there's nothing after it.
  VoidCallback? get _nextMonth =>
      _month.isBefore(_thisMonth()) ? () => _moveMonth(1) : null;

  @override
  Widget build(BuildContext context) {
    final childrenState = context.select(
      (ChildrenViewModel viewModel) => viewModel.state.children,
    );
    final children = childrenState.data ?? const <ChildEntity>[];

    return BlocListener<ChildrenViewModel, ChildrenState>(
      // The children arrived or changed (a child linked, the list
      // refreshed), or another one was picked, here or on another page.
      listenWhen: (previous, current) =>
          previous.children.data != current.children.data ||
          current.showsOtherChildThan(previous),
      listener: (context, state) => _loadChild(),
      child: PageRefresher(
        path: AppRoutes.attendance,
        onRefresh: _refresh,
        child: ParentTabPage(
          title: context.l10n.attendance,
          selectedChild: context.watchSelectedChildIndex(),
          onChildSelected: (index) =>
              context.selectChild(children[index].studentId),
          children: [
            if (children.isEmpty)
              NoChildrenState(
                children: childrenState,
                loading: const AttendanceSkeleton(),
              )
            else
              BlocBuilder<AttendanceViewModel, AttendanceState>(
                builder: (context, state) => state.when(
                  initial: () => const AttendanceSkeleton(),
                  loading: () => const AttendanceSkeleton(),
                  // The arrows stay, so a month that didn't load isn't a dead
                  // end.
                  error: (exception) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MonthSwitcher(
                        month: _month,
                        onPrevious: _previousMonth,
                        onNext: _nextMonth,
                      ),
                      StateMessage(
                        icon: AppIcons.navAttendance,
                        title: exception.localizedMessage(context),
                        action: RetryOrLogInButton(
                          exception: exception,
                          onRetry: _loadMonth,
                        ),
                      ),
                    ],
                  ),
                  success: (attendance) => _attendance(context, attendance),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _attendance(BuildContext context, MonthAttendanceEntity attendance) {
    final l10n = context.l10n;
    final counts = attendance.counts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 18.h,
      children: [
        AttendanceSummaryCard(counts: counts),
        EqualHeightGrid(
          columns: 3,
          spacing: 10.w,
          children: [
            AttendanceCountTile(
              count: counts.presentDays,
              label: l10n.present,
              style: CountTileStyle.present,
            ),
            AttendanceCountTile(
              count: counts.absentDays,
              label: l10n.absent,
              style: CountTileStyle.solid,
            ),
            AttendanceCountTile(
              count: counts.excusedDays,
              label: l10n.excused,
              style: CountTileStyle.info,
            ),
          ],
        ),
        // An absence with an excuse sent shows as excused.
        BlocSelector<
          ExcusableAbsencesViewModel,
          ExcusableAbsencesState,
          Set<DateTime>
        >(
          selector: (state) => state.data?.excuseDates ?? const {},
          builder: (context, excuseDates) => MonthCalendar(
            attendance: attendance,
            excuseDates: excuseDates,
            onPrevious: _previousMonth,
            onNext: _nextMonth,
          ),
        ),
        BlocBuilder<ExcusableAbsencesViewModel, ExcusableAbsencesState>(
          builder: (context, state) {
            final excuses = state.data;
            return AttendanceEventsSection(
              attendance: attendance,
              excuses: excuses,
              onSubmitExcuse: (absence) =>
                  _submitExcuse(absence, excuses!.rules),
              onOpenExcuse: (excuseId) =>
                  _openExcuse(excuseId, rules: excuses?.rules),
            );
          },
        ),
      ],
    );
  }
}
