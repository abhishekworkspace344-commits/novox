import 'package:flutter/material.dart';

/// Lays cards out in columns when there is room and stacks them on phones.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.maxColumns = 3,
    this.minItemWidth = 300,
    this.spacing = 12,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth)
            .floor()
            .clamp(1, maxColumns);
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
