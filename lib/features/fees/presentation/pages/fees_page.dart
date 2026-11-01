import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/icon_box.dart';
import 'package:al_mahhaba_school/core/widgets/progress_bar.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/fees/data/mock_fees.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// The school year's fees for the selected child: what's left to pay,
/// installments and receipts.
class FeesPage extends StatefulWidget {
  const FeesPage({super.key});

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  int _selectedChild = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = mockFees[_selectedChild];

    return ParentTabPage(
      title: l10n.fees,
      tab: MainTab.fees,
      selectedChild: _selectedChild,
      onChildSelected: (index) => setState(() => _selectedChild = index),
      children: [
        _SummaryCard(items),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            SectionTitle(l10n.installments),
            for (final item in items) _InstallmentRow(item),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            SectionTitle(l10n.receipts),
            for (final item in items.where((i) => i.isPaid)) _ReceiptRow(item),
          ],
        ),
      ],
    );
  }
}

/// "EGP 15,000" / "١٥٬٠٠٠ ج.م"
String _money(BuildContext context, int amount) {
  final locale = Localizations.localeOf(context).toString();
  return context.l10n.egpAmount(
    NumberFormat.decimalPattern(locale).format(amount),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(this.items);

  final List<FeeItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final total = items.fold(0, (sum, i) => sum + i.amount);
    final paid = items
        .where((i) => i.isPaid)
        .fold(0, (sum, i) => sum + i.amount);
    final remaining = total - paid;
    final caption = textTheme.bodySmall?.copyWith(color: AppColors.slate);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(l10n.schoolYear(mockSchoolYear), style: caption),
              ),
              Text(
                l10n.percentPaid('${(paid / total * 100).round()}%'),
                style: caption?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.mahabbahRed,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.h,
            children: [
              Text(l10n.remaining, style: caption),
              Text(
                _money(context, remaining),
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 28.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          ProgressBar(
            value: paid / total,
            height: 8,
            trackColor: AppColors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.paidAmount(_money(context, paid)), style: caption),
              Text(l10n.totalAmount(_money(context, total)), style: caption),
            ],
          ),
          if (remaining > 0)
            ElevatedButton(
              // TODO: online payment.
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                textStyle: textTheme.labelLarge?.copyWith(fontSize: 15.sp),
              ),
              child: Text(l10n.payAmount(_money(context, remaining))),
            )
          else
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8.w,
                children: [
                  AppSvgIcon(
                    AppIcons.check,
                    size: 18.r,
                    color: AppColors.mahabbahRed,
                  ),
                  Text(
                    l10n.allFeesPaid,
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 15.sp,
                      color: AppColors.mahabbahRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow(this.item);

  final FeeItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final bold = textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          IconBox(AppIcons.navFees, size: 40.r, iconSize: 18.r, radius: 12.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(item.name, style: bold),
                Text(
                  item.when,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4.h,
            children: [
              Text(_money(context, item.amount), style: bold),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: ShapeDecoration(
                  color: item.isPaid ? AppColors.blush : AppColors.mahabbahRed,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  item.isPaid ? l10n.paid : l10n.due,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: item.isPaid
                        ? AppColors.mahabbahRed
                        : AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.item);

  final FeeItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // TODO: open the receipt PDF.
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            spacing: 12.w,
            children: [
              IconBox(
                AppIcons.fileReport,
                size: 40.r,
                iconSize: 18.r,
                radius: 12.r,
                background: AppColors.white,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2.h,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.when,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                context.l10n.pdf,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.actionRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
