import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/load_more_indicator.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_card.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';

/// The homework, from the [HomeworkBloc]: loading, why it didn't load
/// (with "Try again"), none, or the cards, more loading as the end comes
/// near. Pulled down, it loads again.
///
/// A card is built only as it comes on screen and keeps its place by its
/// homework; an unread one marks itself seen as it comes.
class HomeworkList extends StatelessWidget {
  const HomeworkList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeworkBloc, HomeworkState>(
      // Not as files download: their links show that themselves.
      buildWhen: (previous, current) =>
          previous.homework != current.homework ||
          previous.filter != current.filter ||
          previous.subjectId != current.subjectId,
      builder: (context, state) {
        final l10n = context.l10n;
        final bloc = context.read<HomeworkBloc>();
        void reload() => bloc.add(const ReloadHomeworkIntent());

        final page = state.page;
        if (page == null) {
          final exception = state.homework.exception;
          if (exception == null) return const AppLoading();
          return CenteredStateMessage(
            icon: AppIcons.book,
            title: exception.localizedMessage(context),
            action: RetryOrLogInButton(exception: exception, onRetry: reload),
          );
        }

        final Widget? footer = !page.hasMore
            ? null
            : state.homework.state == StateType.error
            ? Center(
                child: TextButton(
                  onPressed: () => bloc.add(const LoadMoreHomeworkIntent()),
                  child: Text(l10n.tryAgain),
                ),
              )
            // A new one per page, so each asks for the page after it.
            : LoadMoreIndicator(
                key: ValueKey('more:${page.page}'),
                onShown: () => bloc.add(const LoadMoreHomeworkIntent()),
              );
        final items = page.items;
        final count = items.length + (footer == null ? 0 : 1);
        final indexOf = {
          for (final (i, homework) in items.indexed) ValueKey(homework.id): i,
        };

        return RefreshIndicator(
          onRefresh: () async {
            reload();
            // Spins until it's back (or the page closed).
            await bloc.stream.firstWhere(
              (state) => state.homework.state != StateType.loading,
              orElse: () => bloc.state,
            );
          },
          child: items.isEmpty
              ? CenteredStateMessage(
                  icon: AppIcons.book,
                  title: state.isFiltered
                      ? l10n.noHomeworkFiltered
                      : l10n.noHomework,
                  subtitle: state.isFiltered
                      ? l10n.noHomeworkFilteredHint
                      : l10n.noHomeworkHint,
                )
              : ListView.builder(
                  // Pulled down even when it's short.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    math.max(24.h, MediaQuery.paddingOf(context).bottom + 16),
                  ),
                  itemCount: count,
                  findChildIndexCallback: (key) => indexOf[key],
                  itemBuilder: (context, index) {
                    if (index == items.length) return footer!;
                    final homework = items[index];
                    return Padding(
                      key: ValueKey(homework.id),
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _Seen(
                        onSeen: _seen(bloc, homework),
                        child: HomeworkCard(homework),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  /// Marks [homework] read once it's on screen; null when it's read
  /// already.
  static VoidCallback? _seen(HomeworkBloc bloc, HomeworkEntity homework) {
    final chatKey = homework.chatKey;
    if (homework.isRead || chatKey == null) return null;
    return () => bloc.add(HomeworkSeenIntent(chatKey));
  }
}

/// Calls [onSeen] once, as its card is first built: it's on screen, or
/// about to be.
class _Seen extends StatefulWidget {
  const _Seen({required this.onSeen, required this.child});

  final VoidCallback? onSeen;
  final Widget child;

  @override
  State<_Seen> createState() => _SeenState();
}

class _SeenState extends State<_Seen> {
  @override
  void initState() {
    super.initState();
    widget.onSeen?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
