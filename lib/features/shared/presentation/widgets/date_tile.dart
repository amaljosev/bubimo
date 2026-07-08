// lib/features/shared/presentation/widgets/date_tile.dart

import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';

/// Compact "month abbreviation + big day number" tile shown once per
/// day group in date-grouped lists.
///
/// Previously duplicated as `HomePage._dateTile`. [DiaryListItem]'s
/// own `showDateColumn` variant renders a slightly different layout
/// (day-number-first, weekday below) and is left as-is since its
/// visual spec genuinely differs; this widget covers the "month
/// abbreviation on top" variant used by Home's day-grouped list.
class DateTile extends StatelessWidget {
  final DateTime date;
  final double width;

  const DateTile({super.key, required this.date, this.width = 56});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppDateUtils.monthAbbrUpper(date.month),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            AppDateUtils.dayOfMonthPadded(date),
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}