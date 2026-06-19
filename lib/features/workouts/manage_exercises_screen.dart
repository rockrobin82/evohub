import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/exercise_log_store.dart';
import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../workout_session/exercise_configuration_screen.dart';
import 'models.dart';

class ManageExercisesScreen extends StatefulWidget {
  const ManageExercisesScreen({
    super.key,
    required this.plan,
    required this.day,
  });

  final WorkoutPlan plan;
  final WorkoutDay day;

  @override
  State<ManageExercisesScreen> createState() => _ManageExercisesScreenState();
}

class _ManageExercisesScreenState extends State<ManageExercisesScreen> {
  ExerciseLogStore? _store;
  Map<String, ExerciseProgressionConfig> _configs = {};
  Map<String, ExerciseProgressState> _progressStates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Exercises')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEffectiveSettings,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(widget.plan.name, style: theme.textTheme.headlineMedium),
              EvoSpacing.gapXs,
              Text('Dzień ${widget.day.name}', style: theme.textTheme.titleMedium),
              EvoSpacing.gapSm,
              Text(
                'Edytuj progresję ćwiczeń bez rozpoczynania treningu.',
                style: theme.textTheme.bodySmall,
              ),
              EvoSpacing.gapXl,
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                for (final exercise in widget.day.exercises) ...[
                  _ExerciseManagementTile(
                    exercise: exercise,
                    config: _effectiveConfigFor(exercise),
                    onTap: () => _openConfiguration(exercise),
                  ),
                  EvoSpacing.gapMd,
                ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeStore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;

    _store = ExerciseLogStore(preferences);
    await _loadEffectiveSettings();
  }

  Future<void> _loadEffectiveSettings() async {
    final store = _store;
    if (store == null) return;

    final configs = await store.loadProgressionConfigs();
    final progressStates = await store.loadProgressStates();

    if (!mounted) return;

    setState(() {
      _configs = configs;
      _progressStates = progressStates;
      _isLoading = false;
    });
  }

  ExerciseProgressionConfig _effectiveConfigFor(Exercise exercise) {
    final baseConfig =
        _configs[exercise.id] ?? ExerciseProgressionConfig.fromExercise(exercise);
    final progressState = _progressStates[exercise.id];

    if (progressState == null) return baseConfig;

    return baseConfig.copyWith(
      currentWeightKg: progressState.currentWeightKg,
      currentTargetReps: progressState.currentTargetReps,
    );
  }

  Future<void> _openConfiguration(Exercise exercise) async {
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ExerciseConfigurationScreen(exercise: exercise),
      ),
    );

    if (!mounted || didChange != true) return;

    await _loadEffectiveSettings();
  }
}

class _ExerciseManagementTile extends StatelessWidget {
  const _ExerciseManagementTile({
    required this.exercise,
    required this.config,
    required this.onTap,
  });

  final Exercise exercise;
  final ExerciseProgressionConfig config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EvoCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(EvoRadii.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: theme.textTheme.titleMedium),
                    EvoSpacing.gapSm,
                    Text(
                      '${_formatWeight(config.currentWeightKg)}kg × ${config.currentTargetReps}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: EvoColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    EvoSpacing.gapXs,
                    Text(
                      '${config.minReps}-${config.maxReps} reps',
                      style: theme.textTheme.bodySmall,
                    ),
                    EvoSpacing.gapXs,
                    Text(
                      '+${_formatWeight(config.weightIncrementKg)}kg',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: EvoColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
