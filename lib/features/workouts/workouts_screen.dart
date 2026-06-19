import 'package:flutter/material.dart';

import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../workout_session/workout_day_screen.dart';
import 'manage_exercises_screen.dart';
import 'models.dart';
import 'sample_workout_plans.dart';
import 'workout_plan_section.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          Row(
            children: [
              const _LogoMark(),
              const SizedBox(width: EvoSpacing.sm),
              const Text(
                'EvoHub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Powiadomienia',
              ),
            ],
          ),
          EvoSpacing.gapXl,
          Text('Cześć, Michał!', style: theme.textTheme.headlineMedium),
          EvoSpacing.gapXs,
          Text('Gotowy na trening?', style: theme.textTheme.bodySmall),
          EvoSpacing.gapXl,
          Text('Twoje plany', style: theme.textTheme.titleMedium),
          EvoSpacing.gapMd,
          for (final plan in sampleWorkoutPlans)
            WorkoutPlanSection(
              plan: plan,
              onStartDay: (plan, day) => _startWorkoutDay(context, plan, day),
              onManageDay: (plan, day) =>
                  _manageWorkoutDay(context, plan, day),
            ),
        ],
      ),
    );
  }

  void _startWorkoutDay(
    BuildContext context,
    WorkoutPlan plan,
    WorkoutDay day,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkoutDayScreen(plan: plan, day: day),
      ),
    );
  }

  void _manageWorkoutDay(
    BuildContext context,
    WorkoutPlan plan,
    WorkoutDay day,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManageExercisesScreen(plan: plan, day: day),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: EvoColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'E',
        style: TextStyle(
          color: EvoColors.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }
}
