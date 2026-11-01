import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_back_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_button.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';
import 'package:al_mahhaba_school/core/widgets/red_header.dart';
import 'package:al_mahhaba_school/core/widgets/scrollable_fill.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/auth_header_title.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/linked_child_card.dart';
import 'package:al_mahhaba_school/features/children/data/mock_children.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_profile.dart';

/// Last sign-up step: link children by their national ID.
class AddChildrenPage extends StatefulWidget {
  const AddChildrenPage({super.key});

  @override
  State<AddChildrenPage> createState() => _AddChildrenPageState();
}

class _AddChildrenPageState extends State<AddChildrenPage> {
  static const int _idLength = 14;

  final TextEditingController _idController = TextEditingController();
  final List<ChildProfile> _children = [mockChildren.first];

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _addChild() {
    // TODO: look the ID up in the school records (Cubit). Mock for now.
    final id = _idController.text;
    final found =
        mockChildrenToLink[_children.length % mockChildrenToLink.length];
    setState(() {
      _children.add(
        ChildProfile(
          fullName: found.fullName,
          grade: found.grade,
          idTail: id.substring(id.length - 4),
        ),
      );
      _idController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final idLength = _idController.text.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.mahabbahRed,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RedHeader(
              horizontalPadding: 24,
              bottomPadding: 38,
              watermarkTop: 74,
              watermarkSize: const Size(250, 178),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.h,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppBackButton(fallbackRoute: AppRoutes.otp),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.white.withValues(alpha: 0.16),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          l10n.lastStep,
                          style: textTheme.bodySmall?.copyWith(
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AuthHeaderTitle(
                    title: l10n.addYourChildren,
                    subtitle: l10n.addChildrenSubtitle,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.white,
                child: ScrollableFill(
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    24.h,
                    24.w,
                    math.max(32.h, bottomInset + 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16.h,
                    children: [
                      AppTextField(
                        controller: _idController,
                        label: l10n.childNationalId,
                        labelTrailing: Text(
                          '$idLength / $_idLength',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.slate,
                          ),
                        ),
                        hint: l10n.nationalIdDigitsHint,
                        prefixIcon: AppIcons.idCard,
                        keyboardType: TextInputType.number,
                        letterSpacing: 0.5,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(_idLength),
                        ],
                        onChanged: (_) => setState(() {}),
                        helperText: l10n.nationalIdMatchNote,
                        action: ElevatedButton(
                          onPressed: idLength == _idLength ? _addChild : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, 54.h),
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                          child: Text(l10n.add),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.yourChildren,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 16.sp,
                              height: 1.3,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 3.h,
                            ),
                            decoration: const ShapeDecoration(
                              color: AppColors.blush,
                              shape: StadiumBorder(),
                            ),
                            child: Text(
                              l10n.childrenCount(_children.length),
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.mahabbahRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_children.isEmpty)
                        const NoChildrenCard()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 10.h,
                          children: [
                            for (final (index, child) in _children.indexed)
                              LinkedChildCard(
                                child: child,
                                onRemove: () =>
                                    setState(() => _children.removeAt(index)),
                              ),
                          ],
                        ),
                      const Spacer(),
                      AppButton(
                        label: l10n.continueButton,
                        onPressed: _children.isEmpty
                            ? null
                            : () => context.go(AppRoutes.home),
                        trailingIcon: AppSvgIcon(
                          AppIcons.arrowRight,
                          size: 20.r,
                          matchTextDirection: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
