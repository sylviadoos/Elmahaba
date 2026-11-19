import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_loading.dart';
import 'package:al_mahhaba_school/core/widgets/state_message.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/retry_or_log_in_button.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';
import 'package:al_mahhaba_school/features/homework/presentation/widgets/homework_card.dart';

/// Under the header of one homework's page, from the [HomeworkBloc]: its
/// card, or loading it, why it didn't load ("Try again": [onRetry]), or
/// that it's no longer there.
class HomeworkDetailsBody extends StatelessWidget {
  const HomeworkDetailsBody({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeworkBloc, HomeworkState>(
      // Not as files download: their links show that themselves.
      buildWhen: (previous, current) => previous.one != current.one,
      builder: (context, state) => state.one.when(
        initial: () => const AppLoading(),
        loading: () => const AppLoading(),
        error: (exception) => CenteredStateMessage(
          icon: AppIcons.book,
          title: exception.localizedMessage(context),
          action: RetryOrLogInButton(exception: exception, onRetry: onRetry),
        ),
        success: (homework) => homework == null
            ? CenteredStateMessage(
                icon: AppIcons.book,
                title: context.l10n.homeworkNotFound,
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  8.h,
                  20.w,
                  math.max(24.h, MediaQuery.paddingOf(context).bottom + 16),
                ),
                child: HomeworkCard(homework),
              ),
      ),
    );
  }
}
