import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/skeleton.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';

/// The newest few of one thing on Home (announcements, homework or
/// results): its icon and [title], how many are new and "See all", then a
/// row per item ([row]), [emptyText] when there are none, or "Try again"
/// when they couldn't load.
class LatestCard<T> extends StatelessWidget {
  const LatestCard({
    super.key,
    required this.title,
    required this.icon,
    required this.latest,
    required this.row,
    required this.emptyText,
    required this.onSeeAll,
    required this.onRetry,
  });

  final String title;
  final String icon;
  final BaseState<LatestItemsEntity<T>> latest;
  final Widget Function(T item) row;
  final String emptyText;
  final VoidCallback onSeeAll;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final unread = latest.data?.unread ?? 0;

    return Material(
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: title, icon: icon, unread: unread, onSeeAll: onSeeAll),
          const Divider(height: 1, thickness: 1, color: AppColors.hairline),
          latest.when(
            initial: () => const _Loading(),
            loading: () => const _Loading(),
            error: (exception) => _Message(
              text: exception.localizedMessage(context),
              onRetry: onRetry,
            ),
            success: (latest) => latest.items.isEmpty
                ? _Message(text: emptyText)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (index, item) in latest.items.indexed) ...[
                        if (index > 0)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 14.w,
                            endIndent: 14.w,
                            color: AppColors.hairline,
                          ),
                        row(item),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.unread,
    required this.onSeeAll,
  });

  final String title;
  final String icon;
  final int unread;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 10.h, 6.w, 10.h),
      child: Row(
        spacing: 10.w,
        children: [
          IconBox(icon, size: 30.r, iconSize: 15.r, radius: 9.r),
          // The title as wide as it needs, the "new" count right after it.
          Expanded(
            child: Row(
              spacing: 8.w,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      context.l10n.newCount(unread),
                      maxLines: 1,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mahabbahRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2.w,
                children: [
                  Text(
                    context.l10n.seeAll,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mahabbahRed,
                    ),
                  ),
                  AppSvgIcon(
                    AppIcons.chevronRight,
                    size: 14.r,
                    color: AppColors.mahabbahRed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two rows' shape while they load.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    Widget row() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.h,
        children: [
          SkeletonBar(width: 170.w, height: 11.h),
          SkeletonBar(width: 110.w, height: 9.h),
        ],
      ),
    );

    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [row(), row()],
      ),
    );
  }
}

/// None yet, or why they couldn't load with "Try again".
class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final onRetry = this.onRetry;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        14.w,
        onRetry == null ? 14.h : 6.h,
        6.w,
        onRetry == null ? 14.h : 6.h,
      ),
      child: Row(
        spacing: 8.w,
        children: [
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.sp,
                color: AppColors.slate,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mahabbahRed,
                textStyle: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(context.l10n.tryAgain),
            ),
        ],
      ),
    );
  }
}
