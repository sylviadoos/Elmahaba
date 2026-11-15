import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/result_labels.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/school_order.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_filter_chip.dart';

/// Every result published, in the school year's order — October,
/// November, the first term, March… — as chips in a row that scrolls
/// sideways: a month by its name, a term by its title. Tapping one shows
/// it; the one shown is scrolled to.
class ResultFilter extends StatefulWidget {
  const ResultFilter({
    super.key,
    required this.results,
    required this.selectedId,
    required this.onSelected,
  });

  /// In any order.
  final List<ResultDetailsEntity> results;
  final int selectedId;
  final ValueChanged<int> onSelected;

  @override
  State<ResultFilter> createState() => _ResultFilterState();
}

class _ResultFilterState extends State<ResultFilter> {
  /// The chip of the one shown.
  final _selectedChip = GlobalKey();

  @override
  void initState() {
    super.initState();
    _showSelected();
  }

  @override
  void didUpdateWidget(ResultFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another child's: the newest may be off the screen again.
    if (oldWidget.results != widget.results) _showSelected();
  }

  /// The newest is usually the last chip: brought on screen, without
  /// moving the page.
  void _showSelected() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final chip = _selectedChip.currentContext;
    if (chip == null || !chip.mounted) return;
    Scrollable.ensureVisible(
      chip,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Past the page's padding, so the chips scroll to its edges.
      clipBehavior: Clip.none,
      child: Row(
        spacing: 8.w,
        children: [
          for (final result in widget.results.inSchoolOrder())
            ResultFilterChip(
              key: result.id == widget.selectedId ? _selectedChip : null,
              label: result.label(context),
              isSelected: result.id == widget.selectedId,
              onTap: () => widget.onSelected(result.id),
            ),
        ],
      ),
    );
  }
}
