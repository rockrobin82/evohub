import 'package:flutter/material.dart';

import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../../widgets/primary_cta_button.dart';
import '../workouts/models.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({
    super.key,
    required this.plan,
    required this.day,
    required this.exercisesCompleted,
    required this.setsCompleted,
    required this.startedAt,
  });

  final WorkoutPlan plan;
  final WorkoutDay day;
  final int exercisesCompleted;
  final int setsCompleted;
  final DateTime startedAt;

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(startedAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Podsumowanie')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: EvoColors.primary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: EvoColors.primary,
                  size: 52,
                ),
              ),
              EvoSpacing.gapXl,
              Text(
                'Świetna robota!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              EvoSpacing.gapSm,
              Text(
                '${plan.name} • Dzień ${day.name}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              EvoSpacing.gapXl,
              EvoCard(
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Ćwiczenia ukończone',
                      value: '$exercisesCompleted',
                    ),
                    const Divider(color: EvoColors.border),
                    _SummaryRow(label: 'Serie wykonane', value: '$setsCompleted'),
                    const Divider(color: EvoColors.border),
                    _SummaryRow(
                      label: 'Czas treningu',
                      value: _formatDuration(duration),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryCtaButton(
                label: 'Powrót do Dashboard',
                icon: Icons.home_rounded,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
