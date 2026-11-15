import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_route_observer.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/load_more_indicator.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaint_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_event.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_state.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/view_model/my_complaints_view_model.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaint_card.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/complaints_skeleton.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/no_complaints_message.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/widgets/status_filter_chip.dart';
import 'package:al_mahhaba_school/features/profile/presentation/widgets/settings_button.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// The parent's complaints, newest first: all, the open or the closed ones.
/// More load as the list scrolls; "New complaint" files another.
class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MyComplaintsViewModel>()..doAction(const LoadComplaintsEvent()),
      child: const _ComplaintsView(),
    );
  }
}

class _ComplaintsView extends StatefulWidget {
  const _ComplaintsView();

  @override
  State<_ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<_ComplaintsView> with RouteAware {
  /// Null shows them all; otherwise the open ones, or the closed ones.
  bool? _open;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) case final PageRoute<dynamic> route) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// Back from a complaint, a new one, or the one that new one showed: the
  /// list loads again. One may have been sent, or changed status (a reply
  /// puts it in review).
  @override
  void didPopNext() => _refresh();

  void _load() => context.read<MyComplaintsViewModel>().doAction(
    const LoadComplaintsEvent(),
  );

  void _loadMore() => context.read<MyComplaintsViewModel>().doAction(
    const LoadMoreComplaintsEvent(),
  );

  void _refresh() => context.read<MyComplaintsViewModel>().doAction(
    const LoadComplaintsEvent(refresh: true),
  );

  /// The list loads again on the way back ([didPopNext]).
  void _newComplaint() => context.push(AppRoutes.newComplaint);

  /// The list loads again on the way back ([didPopNext]).
  void _openComplaint(ComplaintEntity complaint) => context.push(
    AppRoutes.complaintDetailsOf(complaint.id),
    extra: complaint,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final buttonBottom = math.max(
      28.h,
      MediaQuery.paddingOf(context).bottom + 12,
    );

    return BlocConsumer<MyComplaintsViewModel, MyComplaintsState>(
      // The next page failed; the ones loaded stay.
      listenWhen: (_, state) =>
          state.state == StateType.error && state.data != null,
      listener: (context, state) => context.showSnackBar(
        state.exception!.localizedMessage(context),
        isError: true,
      ),
      builder: (context, state) {
        final loaded = state.data;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RedHeader(
                      horizontalPadding: 16,
                      bottomPadding: 40,
                      watermarkTop: 20,
                      watermarkSize: const Size(200, 143),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12.h,
                        children: [
                          Row(
                            spacing: 10.w,
                            children: [
                              const AppBackButton(
                                fallbackRoute: AppRoutes.home,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.complaints,
                                      style: textTheme.headlineMedium?.copyWith(
                                        fontSize: 24.sp,
                                        height: 28 / 24,
                                        letterSpacing: 0,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    if (loaded != null)
                                      Text(
                                        _counts(context, loaded),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.white.withValues(
                                            alpha: 0.88,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SettingsButton(),
                            ],
                          ),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              for (final (open, label) in [
                                (null, l10n.filterAll),
                                (true, l10n.filterOpen),
                                (false, l10n.filterClosed),
                              ])
                                StatusFilterChip(
                                  label: label,
                                  isSelected: _open == open,
                                  onTap: () => setState(() => _open = open),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: loaded == null
                          ? _firstPage(context, state)
                          : _list(context, state, loaded, buttonBottom),
                    ),
                  ],
                ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: buttonBottom,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mahabbahRed.withValues(alpha: 0.28),
                          offset: Offset(0, 14.h),
                          blurRadius: 30.r,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _newComplaint,
                      icon: AppSvgIcon(
                        AppIcons.plus,
                        size: 18.r,
                        color: AppColors.white,
                      ),
                      label: Text(l10n.newComplaint),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// "5 complaints · 3 open". The open ones are counted once all are
  /// loaded.
  String _counts(BuildContext context, ComplaintsPageEntity loaded) {
    final l10n = context.l10n;
    final total = l10n.complaintsCount(loaded.total);
    if (loaded.hasMore) return total;
    final open = loaded.complaints.where((complaint) => complaint.isOpen);
    return '$total · ${l10n.openCount(open.length)}';
  }

  /// Loading the first page, or why it didn't load.
  Widget _firstPage(BuildContext context, MyComplaintsState state) {
    final exception = state.exception;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      child: exception == null
          ? const ComplaintsSkeleton()
          : StateMessage(
              icon: AppIcons.complaint,
              title: exception.localizedMessage(context),
              action: RetryOrLogInButton(exception: exception, onRetry: _load),
            ),
    );
  }

  Widget _list(
    BuildContext context,
    MyComplaintsState state,
    ComplaintsPageEntity loaded,
    double buttonBottom,
  ) {
    final shown = [
      for (final complaint in loaded.complaints)
        if (_open == null || complaint.isOpen == _open) complaint,
    ];
    final Widget? footer = !loaded.hasMore
        ? null
        : state.state == StateType.error
        ? Center(
            child: TextButton(
              onPressed: _loadMore,
              child: Text(context.l10n.tryAgain),
            ),
          )
        // A new one per page, so each asks for the page after it.
        : LoadMoreIndicator(key: ValueKey(loaded.page), onShown: _loadMore);
    final rows = [
      if (shown.isEmpty && footer == null) const NoComplaintsMessage(),
      for (final complaint in shown)
        ComplaintCard(
          complaint: complaint,
          onTap: () => _openComplaint(complaint),
        ),
      ?footer,
      if (loaded.total > 0)
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            context.l10n.complaintsPageNote(
              loaded.page,
              loaded.lastPage,
              loaded.total,
            ),
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              height: 16 / 12,
              color: AppColors.slate,
            ),
          ),
        ),
    ];

    return ListView.separated(
      // Bottom room so the last one scrolls above the button.
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, buttonBottom + 56.h + 24.h),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
    );
  }
}
