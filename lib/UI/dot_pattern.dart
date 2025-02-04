// given the range of days, create a dot pattern, each dot is a day
// passed dots are grey, future dots are black

import 'package:flutter/material.dart';
import 'dart:math' show sqrt;

class DotPattern extends StatelessWidget {
  final int days;
  final int startDay;
  final bool isYearView;
  final bool isMonthView;
  const DotPattern({
    super.key,
    required this.days,
    required this.startDay,
    this.isYearView = false,
    this.isMonthView = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal dot size and spacing based on screen size
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final area = width * height;
        final dotArea = area /
            (days *
                (isYearView
                    ? 2.0
                    : isMonthView
                        ? 2.5
                        : 1.5)); // Adjusted multiplier for month view
        final dotSize = (sqrt(dotArea) * 0.8).clamp(
          isYearView
              ? 8.0
              : isMonthView
                  ? 5.0
                  : 4.0, // Smaller minimum size for month view
          isYearView
              ? 16.0
              : isMonthView
                  ? 11.5
                  : 12.0, // Smaller maximum size for month view
        );
        final spacing = dotSize *
            (isMonthView ? 0.4 : 1.0); // Reduced spacing for month view

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                30, // Account for status bar and title
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(days, (index) {
                return Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < startDay ? Colors.grey[800] : Colors.white70,
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
