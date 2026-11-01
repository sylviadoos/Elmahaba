import 'package:flutter/material.dart';

/// Fills the available height and only scrolls when [child] is taller
/// (small phones, big fonts, keyboard open). Put a [Spacer] in the child
/// Column to push content — like a bottom button — to the bottom.
class ScrollableFill extends StatelessWidget {
  const ScrollableFill({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
