import 'package:flutter/material.dart';

import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import 'models.dart';
import 'workout_day_card.dart';

class WorkoutPlanSection extends StatelessWidget {
  const WorkoutPlanSection({
    super.key,
    required this.plan,
    required this.onStartDay,
    required this.onManageDay,
  });

  final WorkoutPlan plan;
  final void Function(WorkoutPlan plan, WorkoutDay day) onStartDay;
  final void Function(WorkoutPlan plan, WorkoutDay day) onManageDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EvoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.name, style: theme.textTheme.titleLarge),
              EvoSpacing.gapSm,
              Text(plan.description, style: theme.textTheme.bodySmall),
              EvoSpacing.gapLg,
              Text(
                '${plan.days.length} dni treningowe',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
        EvoSpacing.gapLg,
        for (final day in plan.days) ...[
          WorkoutDayCard(
            day: day,
            onStart: () => onStartDay(plan, day),
            onManage: () => onManageDay(plan, day),
          ),
          EvoSpacing.gapMd,
        ],
      ],
    );
  }
}
