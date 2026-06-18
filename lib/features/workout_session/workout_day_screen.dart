import 'package:flutter/material.dart';

import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../../widgets/primary_cta_button.dart';
import '../workouts/models.dart';
import 'exercise_screen.dart';

class WorkoutDayScreen extends StatelessWidget {
  const WorkoutDayScreen({super.key, required this.plan, required this.day});

  final WorkoutPlan plan;
  final WorkoutDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSets = day.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets,
    );
    final estimatedMinutes = _estimateMinutes(day);

    return Scaffold(
      appBar: AppBar(title: const Text('Trening')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(plan.name, style: theme.textTheme.headlineMedium),
            EvoSpacing.gapXs,
            Text('Dzień ${day.name}', style: theme.textTheme.titleMedium),
            EvoSpacing.gapXl,
            EvoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.focus, style: theme.textTheme.titleMedium),
                  EvoSpacing.gapLg,
                  _InfoRow(
                    icon: Icons.fitness_center_rounded,
                    label: 'Ćwiczenia',
                    value: '${day.exercises.length}',
                  ),
                  EvoSpacing.gapMd,
                  _InfoRow(
                    icon: Icons.repeat_rounded,
                    label: 'Serie',
                    value: '$totalSets',
                  ),
                  EvoSpacing.gapMd,
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Szacowany czas',
                    value: '$estimatedMinutes min',
                  ),
                ],
              ),
            ),
            EvoSpacing.gapXl,
            Text('Lista ćwiczeń', style: theme.textTheme.titleMedium),
            EvoSpacing.gapMd,
            for (final (index, exercise) in day.exercises.indexed) ...[
              EvoCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: EvoColors.primary.withValues(alpha: 0.18),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: EvoColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: EvoSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exercise.name, style: theme.textTheme.titleMedium),
                          EvoSpacing.gapXs,
                          Text(
                            '${exercise.sets} serie • ${exercise.progressionRule.minReps}-${exercise.progressionRule.maxReps} powt. • RIR ${exercise.targetRir}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              EvoSpacing.gapMd,
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: PrimaryCtaButton(
          label: 'Start Workout',
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExerciseScreen(plan: plan, day: day),
              ),
            );
          },
        ),
      ),
    );
  }

  int _estimateMinutes(WorkoutDay day) {
    final restSeconds = day.exercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise.sets * exercise.restSeconds),
    );
    final workSeconds = day.exercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise.sets * 45),
    );
    return ((restSeconds + workSeconds) / 60).round();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: EvoColors.primary, size: 20),
        const SizedBox(width: EvoSpacing.md),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
