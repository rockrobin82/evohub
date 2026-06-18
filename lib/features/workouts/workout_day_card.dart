import 'package:flutter/material.dart';

import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../../widgets/primary_cta_button.dart';
import 'models.dart';

class WorkoutDayCard extends StatelessWidget {
  const WorkoutDayCard({super.key, required this.day, required this.onStart});

  final WorkoutDay day;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exerciseCount = day.exercises.length;
    final totalSets = day.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );

    return EvoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayBadge(label: day.name),
              const SizedBox(width: EvoSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trening ${day.name}', style: theme.textTheme.titleMedium),
                    EvoSpacing.gapXs,
                    Text(day.focus, style: theme.textTheme.bodySmall),
                    if (day.lastCompletedLabel != null) ...[
                      EvoSpacing.gapSm,
                      Text(
                        day.lastCompletedLabel!,
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          EvoSpacing.gapLg,
          Row(
            children: [
              _Metric(icon: Icons.fitness_center, label: '$exerciseCount ćwiczenia'),
              const SizedBox(width: EvoSpacing.lg),
              _Metric(icon: Icons.repeat, label: '$totalSets serii'),
            ],
          ),
          EvoSpacing.gapLg,
          PrimaryCtaButton(
            label: 'Rozpocznij',
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: EvoColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(EvoRadii.small),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: EvoColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: EvoColors.primary, size: 16),
        const SizedBox(width: EvoSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
