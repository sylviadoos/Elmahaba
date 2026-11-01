import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/child_tabs.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/features/chat/data/mock_chat.dart';
import 'package:al_mahhaba_school/features/chat/presentation/widgets/chat_message_card.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/home/data/mock_home.dart';

/// Messages from the school for the selected child. Parents reply by
/// picking one of the options on a message.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedChild = 0;

  /// Message id → chosen option label.
  // TODO: send replies to the API (Cubit).
  final Map<String, String> _answers = {...mockAnswers};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final messages = mockChats[_selectedChild];

    final items = <Widget>[
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          MessageKindChip(isGeneral: true, label: l10n.chatGeneral),
          MessageKindChip(isGeneral: false, label: l10n.chatPrivateOnlyYou),
        ],
      ),
      SizedBox(height: 16.h),
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: const ShapeDecoration(
            color: AppColors.line,
            shape: StadiumBorder(),
          ),
          child: Text(
            l10n.today,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
        ),
      ),
      // Messages are separated by a dashed line, with 18 px around each.
      for (final (index, message) in messages.indexed) ...[
        if (index > 0) const DashedLine(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: ChatMessageCard(
            message: message,
            answer: _answers[message.id],
            onAnswer: (label) => setState(() => _answers[message.id] = label),
          ),
        ),
      ],
    ];

    final title = Row(
      spacing: 10.w,
      children: [
        const AppBackButton(fallbackRoute: AppRoutes.home),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.schoolChat,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  height: 24 / 20,
                  color: AppColors.white,
                ),
              ),
              Text(
                l10n.schoolName,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final tabs = ChildTabs(
      tabs: [
        for (final (index, child) in mockChildren.indexed)
          ChildTab(
            name: child.firstName,
            grade: child.grade,
            unread: mockDashboards[index].unread,
          ),
      ],
      selected: _selectedChild,
      onSelected: (index) => setState(() => _selectedChild = index),
      showUnread: true,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CollapsingHeader(
                      topInset: MediaQuery.paddingOf(context).top,
                      title: title,
                      tabs: tabs,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    sliver: SliverList.list(children: items),
                  ),
                ],
              ),
            ),
            const _ReplyHint(),
          ],
        ),
      ),
    );
  }
}

/// Red header that collapses while the messages scroll: the [title] row
/// drifts up at half speed and fades (parallax) while the child [tabs]
/// stay pinned under the status bar.
class _CollapsingHeader extends SliverPersistentHeaderDelegate {
  _CollapsingHeader({
    required this.topInset,
    required this.title,
    required this.tabs,
  });

  final double topInset;
  final Widget title;
  final Widget tabs;

  static const double _parallax = 0.5;

  double get _top => topInset + 8.h;

  /// Title row (44 px back button) plus the gap above the tabs.
  double get _titleHeight => 44.r + 14.h;

  /// ChildTabs: 48 px tabs inside 4 px padding.
  double get _tabsHeight => 48.h + 8.r;

  /// Space for the wave below the tabs.
  double get _bottom => 36.h;

  @override
  double get minExtent => _top + _tabsHeight + _bottom;

  @override
  double get maxExtent => minExtent + _titleHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final collapsed = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return ClipRect(
      child: ColoredBox(
        color: AppColors.mahabbahRed,
        child: Stack(
          children: [
            PositionedDirectional(
              end: -46.w,
              top:
                  topInset +
                  (20 - RedHeader.designStatusBar).h -
                  shrinkOffset * 0.3,
              child: const HeaderWatermark(size: Size(200, 143)),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              top: _top - shrinkOffset * _parallax,
              child: IgnorePointer(
                ignoring: collapsed > 0.5,
                child: Opacity(
                  opacity: (1 - collapsed * 1.6).clamp(0.0, 1.0),
                  child: title,
                ),
              ),
            ),
            Positioned(left: 16.w, right: 16.w, bottom: _bottom, child: tabs),
            const Positioned(
              left: 0,
              right: 0,
              bottom: -1,
              child: HeaderWave(color: AppColors.surface),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingHeader oldDelegate) => true;
}

class _ReplyHint extends StatelessWidget {
  const _ReplyHint();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        math.max(30.h, bottomInset + 12),
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          IconBox(AppIcons.tapChoose, size: 36.r, iconSize: 17.r, circle: true),
          Expanded(
            child: Text(
              context.l10n.chatReplyHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.slate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
