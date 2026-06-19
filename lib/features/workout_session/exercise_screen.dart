import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/exercise_log_store.dart';
import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../../widgets/primary_cta_button.dart';
import '../workouts/models.dart';
import 'exercise_configuration_screen.dart';
import 'rest_timer_screen.dart';
import 'workout_summary_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key, required this.plan, required this.day});

  final WorkoutPlan plan;
  final WorkoutDay day;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final DateTime _startedAt = DateTime.now();
  int _exerciseIndex = 0;
  int _completedSetsForExercise = 0;
  int _totalCompletedSets = 0;
  late int _reps;
  late int _rir;
  late double _weightKg;
  late ProgressionRule _rule;
  ExerciseLogStore? _store;
  ExerciseLog? _latestLog;
  bool _isLoadingStoredState = true;

  Exercise get _exercise => widget.day.exercises[_exerciseIndex];

  @override
  void initState() {
    super.initState();
    _loadExerciseDefaults();
    _initializeStore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = _exercise;
    final suggestion = _rule.nextSuggestion(
      currentWeightKg: _weightKg,
      currentTargetReps: _reps,
      achievedReps: _reps,
    );
    final totalExercises = widget.day.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dzień ${widget.day.name}'),
        actions: [
          IconButton(
            tooltip: 'Konfiguracja ćwiczenia',
            onPressed: _openExerciseConfiguration,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Exercise ${_exerciseIndex + 1} of $totalExercises',
              style: theme.textTheme.labelMedium,
            ),
            EvoSpacing.gapSm,
            Text(exercise.name, style: theme.textTheme.headlineMedium),
            EvoSpacing.gapSm,
            Text(exercise.description, style: theme.textTheme.bodySmall),
            EvoSpacing.gapXl,
            _TodayTargetCard(
              targetReps: _reps,
              sets: exercise.sets,
              rir: exercise.targetRir,
            ),
            EvoSpacing.gapLg,
            _ProgressionInfoCard(
              lastWorkout: _isLoadingStoredState
                  ? 'Ładowanie...'
                  : _formatLastWorkout(_latestLog),
              currentTarget: '${_formatWeight(_weightKg)} kg × $_reps',
              nextStep:
                  '${_formatWeight(suggestion.weightKg)} kg × ${suggestion.targetReps}',
            ),
            EvoSpacing.gapLg,
            _AdvancedSection(
              rule: _rule,
              rir: _rir,
              onRirDecrement: _rir > 0 ? () => setState(() => _rir -= 1) : null,
              onRirIncrement: _rir < 5 ? () => setState(() => _rir += 1) : null,
            ),
            EvoSpacing.gapLg,
            EvoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wpis serii', style: theme.textTheme.titleMedium),
                  EvoSpacing.gapLg,
                  _StepControl<int>(
                    label: 'Powtórzenia',
                    value: _reps,
                    decrementLabel: '-',
                    incrementLabel: '+',
                    onDecrement: _reps > 1
                        ? () => setState(() => _reps -= 1)
                        : null,
                    onIncrement: _reps < 50
                        ? () => setState(() => _reps += 1)
                        : null,
                  ),
                  EvoSpacing.gapLg,
                  _WeightControl(
                    value: _weightKg,
                    increment: _rule.weightIncrementKg,
                    onChanged: (value) => setState(() => _weightKg = value),
                  ),
                ],
              ),
            ),
            EvoSpacing.gapLg,
            EvoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wykonane serie', style: theme.textTheme.titleMedium),
                  EvoSpacing.gapMd,
                  Wrap(
                    spacing: EvoSpacing.sm,
                    runSpacing: EvoSpacing.sm,
                    children: [
                      for (var index = 0; index < exercise.sets; index++)
                        _SetChip(
                          setNumber: index + 1,
                          label: 'Set ${index + 1}',
                          state: index < _completedSetsForExercise
                              ? _SetState.completed
                              : index == _completedSetsForExercise
                              ? _SetState.active
                              : _SetState.upcoming,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: PrimaryCtaButton(
          label: 'Seria wykonana',
          icon: Icons.check_circle_outline_rounded,
          onPressed: _completeSet,
        ),
      ),
    );
  }

  Future<void> _completeSet() async {
    setState(() {
      _completedSetsForExercise += 1;
      _totalCompletedSets += 1;
    });
    debugPrint(
      '[ExerciseScreen] completeSet exerciseId=${_exercise.id} '
      'completedSets=$_completedSetsForExercise/${_exercise.sets} '
      'weightKg=$_weightKg reps=$_reps rir=$_rir',
    );

    if (_completedSetsForExercise >= _exercise.sets) {
      debugPrint(
        '[ExerciseScreen] exercise complete; saving log for '
        'exerciseId=${_exercise.id}',
      );
      await _saveCompletedExercise();
    }

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RestTimerScreen(seconds: _exercise.restSeconds),
      ),
    );

    if (!mounted) return;

    if (_completedSetsForExercise >= _exercise.sets) {
      _advanceExercise();
    }
  }

  void _loadExerciseDefaults() {
    final exercise = _exercise;
    _reps = exercise.currentTargetReps;
    _rir = exercise.targetRir;
    _weightKg = exercise.currentWeightKg;
    _rule = exercise.progressionRule;
    _latestLog = null;
    _isLoadingStoredState = true;
  }

  Future<void> _initializeStore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;

    _store = ExerciseLogStore(preferences);
    debugPrint('[ExerciseScreen] store initialized; loading startup data');
    await _loadStoredExerciseState();
  }

  Future<void> _loadStoredExerciseState() async {
    final store = _store;
    if (store == null) return;

    final exercise = _exercise;
    debugPrint(
      '[ExerciseScreen] loadStoredExerciseState exerciseId=${exercise.id}',
    );
    final latestLog = await store.latestForExercise(exercise.id);
    final progressionConfig = await store.progressionConfigForExercise(
      exercise.id,
    );
    final progressState = await store.progressStateForExercise(exercise.id);

    if (!mounted || exercise.id != _exercise.id) return;

    setState(() {
      _latestLog = latestLog;
      if (progressionConfig != null) {
        _rule = progressionConfig.progressionRule;
        _weightKg = progressionConfig.currentWeightKg;
        _reps = progressionConfig.currentTargetReps;
      }
      if (progressState != null) {
        _weightKg = progressState.currentWeightKg;
        _reps = progressState.currentTargetReps;
      }
      _isLoadingStoredState = false;
    });
    debugPrint(
      '[ExerciseScreen] loaded startup data exerciseId=${exercise.id} '
      'latestLog=${latestLog == null ? 'null' : '${latestLog.weightKg}kg x ${latestLog.reps} RIR ${latestLog.rir}'} '
      'progressionConfig=${progressionConfig == null ? 'null' : '${progressionConfig.minReps}-${progressionConfig.maxReps} step ${progressionConfig.repStep} +${progressionConfig.weightIncrementKg}kg'} '
      'progressState=${progressState == null ? 'null' : '${progressState.currentWeightKg}kg x ${progressState.currentTargetReps}'}',
    );
  }

  Future<void> _saveCompletedExercise() async {
    final store = _store;
    if (store == null) {
      debugPrint(
        '[ExerciseScreen] save skipped; store is null for exerciseId=${_exercise.id}',
      );
      return;
    }

    final exercise = _exercise;
    final completedLog = ExerciseLog(
      exerciseId: exercise.id,
      completedAt: DateTime.now(),
      weightKg: _weightKg,
      reps: _reps,
      rir: _rir,
    );
    final nextTarget = _rule.nextSuggestion(
      currentWeightKg: _weightKg,
      currentTargetReps: _reps,
      achievedReps: _reps,
    );

    debugPrint(
      '[ExerciseScreen] saveCompletedExercise exerciseId=${exercise.id} '
      'log=${completedLog.weightKg}kg x ${completedLog.reps} RIR ${completedLog.rir} '
      'next=${nextTarget.weightKg}kg x ${nextTarget.targetReps}',
    );
    await store.saveLog(completedLog);
    await store.saveProgressState(
      ExerciseProgressState(
        exerciseId: exercise.id,
        currentWeightKg: nextTarget.weightKg,
        currentTargetReps: nextTarget.targetReps,
      ),
    );
    final progressionConfig = await store.progressionConfigForExercise(
      exercise.id,
    );
    if (progressionConfig != null) {
      await store.saveProgressionConfig(
        progressionConfig.copyWith(
          currentWeightKg: nextTarget.weightKg,
          currentTargetReps: nextTarget.targetReps,
        ),
      );
    }

    if (!mounted || exercise.id != _exercise.id) return;

    setState(() {
      _latestLog = completedLog;
    });
  }

  void _advanceExercise() {
    final isLastExercise = _exerciseIndex == widget.day.exercises.length - 1;

    if (isLastExercise) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => WorkoutSummaryScreen(
            plan: widget.plan,
            day: widget.day,
            exercisesCompleted: widget.day.exercises.length,
            setsCompleted: _totalCompletedSets,
            startedAt: _startedAt,
          ),
        ),
      );
      return;
    }

    setState(() {
      _exerciseIndex += 1;
      _completedSetsForExercise = 0;
      _loadExerciseDefaults();
    });
    _loadStoredExerciseState();
  }

  String _formatLastWorkout(ExerciseLog? log) {
    if (log == null) return 'Brak danych';
    return '${_formatWeight(log.weightKg)} kg × ${log.reps}';
  }

  Future<void> _openExerciseConfiguration() async {
    final didChange = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ExerciseConfigurationScreen(exercise: _exercise),
      ),
    );

    if (!mounted || didChange != true) return;

    _loadExerciseDefaults();
    await _loadStoredExerciseState();
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

class _TodayTargetCard extends StatelessWidget {
  const _TodayTargetCard({
    required this.targetReps,
    required this.sets,
    required this.rir,
  });

  final int targetReps;
  final int sets;
  final int rir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EvoCard(
      child: Column(
        children: [
          Text(
            'CEL NA DZIŚ',
            style: theme.textTheme.labelMedium?.copyWith(
              color: EvoColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          EvoSpacing.gapMd,
          Text(
            '$targetReps × $sets',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.6,
              color: EvoColors.textPrimary,
            ),
          ),
          EvoSpacing.gapSm,
          Text(
            'RIR $rir',
            style: theme.textTheme.titleLarge?.copyWith(
              color: EvoColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressionInfoCard extends StatelessWidget {
  const _ProgressionInfoCard({
    required this.lastWorkout,
    required this.currentTarget,
    required this.nextStep,
  });

  final String lastWorkout;
  final String currentTarget;
  final String nextStep;

  @override
  Widget build(BuildContext context) {
    return EvoCard(
      child: Column(
        children: [
          _ProgressionInfoRow(label: 'Ostatni trening', value: lastWorkout),
          const Divider(color: EvoColors.border),
          _ProgressionInfoRow(label: 'Cel na dziś', value: currentTarget),
          const Divider(color: EvoColors.border),
          _ProgressionInfoRow(label: 'Następny krok', value: nextStep),
        ],
      ),
    );
  }
}

class _ProgressionInfoRow extends StatelessWidget {
  const _ProgressionInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({
    required this.rule,
    required this.rir,
    required this.onRirDecrement,
    required this.onRirIncrement,
  });

  final ProgressionRule rule;
  final int rir;
  final VoidCallback? onRirDecrement;
  final VoidCallback? onRirIncrement;

  @override
  Widget build(BuildContext context) {
    return EvoCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text('Zaawansowane', style: Theme.of(context).textTheme.titleMedium),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          _TargetRow(
            label: 'Zakres powtórzeń',
            value: '${rule.minReps}-${rule.maxReps}',
          ),
          _TargetRow(
            label: 'Reguła progresji',
            value: _formatProgressionType(rule.type),
          ),
          _TargetRow(
            label: 'Skok ciężaru',
            value: '+${_formatWeight(rule.weightIncrementKg)} kg',
          ),
          EvoSpacing.gapLg,
          _StepControl<int>(
            label: 'RIR',
            value: rir,
            decrementLabel: '-',
            incrementLabel: '+',
            onDecrement: onRirDecrement,
            onIncrement: onRirIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepControl<T> extends StatelessWidget {
  const _StepControl({
    required this.label,
    required this.value,
    required this.decrementLabel,
    required this.incrementLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final T value;
  final String decrementLabel;
  final String incrementLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        EvoSpacing.gapSm,
        Row(
          children: [
            _ValueButton(label: decrementLabel, onPressed: onDecrement),
            Expanded(
              child: Center(
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            _ValueButton(label: incrementLabel, onPressed: onIncrement),
          ],
        ),
      ],
    );
  }
}

class _WeightControl extends StatelessWidget {
  const _WeightControl({
    required this.value,
    required this.increment,
    required this.onChanged,
  });

  final double value;
  final double increment;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ciężar', style: Theme.of(context).textTheme.bodySmall),
        EvoSpacing.gapSm,
        Row(
          children: [
            _ValueButton(
              label: '-${_formatWeight(increment)}',
              onPressed: value >= increment
                  ? () => onChanged(value - increment)
                  : null,
            ),
            const SizedBox(width: EvoSpacing.sm),
            _ValueButton(
              label: '-1',
              onPressed: value >= 1 ? () => onChanged(value - 1) : null,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_formatWeight(value)} kg',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            _ValueButton(
              label: '+1',
              onPressed: value < 300 ? () => onChanged(value + 1) : null,
            ),
            const SizedBox(width: EvoSpacing.sm),
            _ValueButton(
              label: '+${_formatWeight(increment)}',
              onPressed: value <= 300 - increment
                  ? () => onChanged(value + increment)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ValueButton extends StatelessWidget {
  const _ValueButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: EvoColors.textPrimary,
          side: const BorderSide(color: EvoColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EvoRadii.small),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _SetChip extends StatelessWidget {
  const _SetChip({
    required this.setNumber,
    required this.label,
    required this.state,
  });

  final int setNumber;
  final String label;
  final _SetState state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _SetState.completed;
    final isActive = state == _SetState.active;
    final color = switch (state) {
      _SetState.completed => EvoColors.success,
      _SetState.active => EvoColors.primary,
      _SetState.upcoming => EvoColors.textSecondary,
    };

    return Chip(
      key: ValueKey(switch (state) {
        _SetState.completed => 'completed-set-$setNumber',
        _SetState.active => 'active-set-$setNumber',
        _SetState.upcoming => 'set-$setNumber',
      }),
      label: Text(isCompleted ? '$label ✓' : label),
      avatar: isCompleted
          ? const Icon(Icons.check_rounded, size: 16, color: EvoColors.success)
          : null,
      backgroundColor: isCompleted || isActive
          ? color.withValues(alpha: 0.12)
          : EvoColors.surfaceHigh,
      labelStyle: TextStyle(
        color: color,
        fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
      ),
      side: BorderSide(color: isActive || isCompleted ? color : EvoColors.border),
    );
  }
}

enum _SetState { completed, active, upcoming }

String _formatProgressionType(ProgressionType type) {
  return switch (type) {
    ProgressionType.doubleProgression => 'Double progression',
    ProgressionType.linearProgression => 'Linear progression',
    ProgressionType.manualProgression => 'Manual progression',
    ProgressionType.timeProgression => 'Time progression',
  };
}

String _formatWeight(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
