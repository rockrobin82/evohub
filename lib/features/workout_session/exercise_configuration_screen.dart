import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/exercise_log_store.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';
import '../../widgets/primary_cta_button.dart';
import '../workouts/models.dart';

class ExerciseConfigurationScreen extends StatefulWidget {
  const ExerciseConfigurationScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<ExerciseConfigurationScreen> createState() =>
      _ExerciseConfigurationScreenState();
}

class _ExerciseConfigurationScreenState
    extends State<ExerciseConfigurationScreen> {
  ExerciseLogStore? _store;
  late double _currentWeightKg;
  late int _currentTargetReps;
  late int _minReps;
  late int _maxReps;
  late int _repStep;
  late double _weightIncrementKg;
  String? _errorText;
  bool _isLoading = true;

  ExerciseProgressionConfig get _planDefaults {
    return ExerciseProgressionConfig.fromExercise(widget.exercise);
  }

  @override
  void initState() {
    super.initState();
    _applyConfig(_planDefaults);
    _initializeStore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Konfiguracja ćwiczenia')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(widget.exercise.name, style: theme.textTheme.headlineMedium),
            EvoSpacing.gapSm,
            Text(
              'Dostosuj cel i regułę progresji dla tego ćwiczenia.',
              style: theme.textTheme.bodySmall,
            ),
            EvoSpacing.gapXl,
            EvoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current State', style: theme.textTheme.titleMedium),
                  EvoSpacing.gapLg,
                  _DoubleStepper(
                    label: 'Current weight',
                    value: _currentWeightKg,
                    step: 1,
                    min: 0,
                    suffix: 'kg',
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() => _currentWeightKg = value),
                  ),
                  EvoSpacing.gapLg,
                  _IntStepper(
                    label: 'Current target reps',
                    value: _currentTargetReps,
                    min: 1,
                    onChanged: _isLoading
                        ? null
                        : (value) =>
                              setState(() => _currentTargetReps = value),
                  ),
                ],
              ),
            ),
            EvoSpacing.gapLg,
            EvoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progression Rule', style: theme.textTheme.titleMedium),
                  EvoSpacing.gapLg,
                  _IntStepper(
                    label: 'Min reps',
                    value: _minReps,
                    min: 1,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() => _minReps = value),
                  ),
                  EvoSpacing.gapLg,
                  _IntStepper(
                    label: 'Max reps',
                    value: _maxReps,
                    min: 1,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() => _maxReps = value),
                  ),
                  EvoSpacing.gapLg,
                  _IntStepper(
                    label: 'Rep step',
                    value: _repStep,
                    min: 1,
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() => _repStep = value),
                  ),
                  EvoSpacing.gapLg,
                  _DoubleStepper(
                    label: 'Weight increment',
                    value: _weightIncrementKg,
                    step: 0.5,
                    min: 0.5,
                    suffix: 'kg',
                    onChanged: _isLoading
                        ? null
                        : (value) =>
                              setState(() => _weightIncrementKg = value),
                  ),
                ],
              ),
            ),
            if (_errorText != null) ...[
              EvoSpacing.gapLg,
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            EvoSpacing.gapXl,
            PrimaryCtaButton(
              label: 'Save',
              icon: Icons.save_outlined,
              onPressed: _isLoading ? null : _save,
            ),
            EvoSpacing.gapMd,
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            EvoSpacing.gapMd,
            TextButton(
              onPressed: _isLoading ? null : _resetToPlanDefaults,
              child: const Text('Reset to plan defaults'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeStore() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;

    final store = ExerciseLogStore(preferences);
    final savedConfig = await store.progressionConfigForExercise(
      widget.exercise.id,
    );
    final savedState = await store.progressStateForExercise(widget.exercise.id);

    if (!mounted) return;

    final baseConfig = savedConfig ?? _planDefaults;
    _applyConfig(
      savedState == null
          ? baseConfig
          : baseConfig.copyWith(
              currentWeightKg: savedState.currentWeightKg,
              currentTargetReps: savedState.currentTargetReps,
            ),
    );
    setState(() {
      _store = store;
      _isLoading = false;
    });
  }

  void _applyConfig(ExerciseProgressionConfig config) {
    _currentWeightKg = config.currentWeightKg;
    _currentTargetReps = config.currentTargetReps;
    _minReps = config.minReps;
    _maxReps = config.maxReps;
    _repStep = config.repStep;
    _weightIncrementKg = config.weightIncrementKg;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    final store = _store;
    if (store == null) return;

    await store.saveProgressionConfig(
      ExerciseProgressionConfig(
        exerciseId: widget.exercise.id,
        currentWeightKg: _currentWeightKg,
        currentTargetReps: _currentTargetReps,
        minReps: _minReps,
        maxReps: _maxReps,
        repStep: _repStep,
        weightIncrementKg: _weightIncrementKg,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _resetToPlanDefaults() async {
    final store = _store;
    if (store == null) return;

    await store.resetProgressionConfigToPlanDefaults(widget.exercise.id);

    if (!mounted) return;
    setState(() {
      _applyConfig(_planDefaults);
      _errorText = null;
    });
    Navigator.of(context).pop(true);
  }

  String? _validate() {
    if (_minReps >= _maxReps) {
      return 'Min reps must be lower than max reps.';
    }
    if (_repStep <= 0) {
      return 'Rep step must be greater than 0.';
    }
    if (_weightIncrementKg <= 0) {
      return 'Weight increment must be greater than 0.';
    }
    if (_currentTargetReps < _minReps || _currentTargetReps > _maxReps) {
      return 'Current target reps must stay within the rep range.';
    }
    return null;
  }
}

class _IntStepper extends StatelessWidget {
  const _IntStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepperRow(
      label: label,
      value: '$value',
      onDecrement: onChanged != null && value > min
          ? () => onChanged!(value - 1)
          : null,
      onIncrement: onChanged == null ? null : () => onChanged!(value + 1),
    );
  }
}

class _DoubleStepper extends StatelessWidget {
  const _DoubleStepper({
    required this.label,
    required this.value,
    required this.step,
    required this.min,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double step;
  final double min;
  final String suffix;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepperRow(
      label: label,
      value: '${_formatNumber(value)} $suffix',
      onDecrement: onChanged != null && value > min
          ? () => onChanged!((value - step).clamp(min, 500))
          : null,
      onIncrement: onChanged == null ? null : () => onChanged!(value + step),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String value;
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
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: onDecrement,
                child: const Text('-'),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: onIncrement,
                child: const Text('+'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
