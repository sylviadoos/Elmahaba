import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A non-scrolling grid whose cells in the same row share the tallest
/// cell's height (like CSS grid). For short, fixed lists of tiles.
class EqualHeightGrid extends StatelessWidget {
  const EqualHeightGrid({
    super.key,
    required this.columns,
    required this.spacing,
    double? runSpacing,
    required this.children,
  }) : runSpacing = runSpacing ?? spacing;

  final int columns;

  /// Gap between cells in a row.
  final double spacing;

  /// Gap between rows.
  final double runSpacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: runSpacing,
      children: [
        for (var start = 0; start < children.length; start += columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing,
              children: [
                for (var i = start; i < start + columns; i++)
                  Expanded(
                    child: i < math.min(children.length, start + columns)
                        ? children[i]
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
