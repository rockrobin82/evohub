class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
  });

  final String id;
  final String name;
  final String description;
  final List<WorkoutDay> days;
}

class WorkoutDay {
  const WorkoutDay({
    required this.id,
    required this.name,
    required this.focus,
    required this.exercises,
    this.lastCompletedLabel,
  });

  final String id;
  final String name;
  final String focus;
  final List<Exercise> exercises;
  final String? lastCompletedLabel;
}

enum ProgressionType {
  doubleProgression,
  linearProgression,
  manualProgression,
  timeProgression,
}

class ProgressionRule {
  const ProgressionRule({
    required this.type,
    required this.minReps,
    required this.maxReps,
    required this.repStep,
    required this.weightIncrementKg,
  });

  final ProgressionType type;
  final int minReps;
  final int maxReps;
  final int repStep;
  final double weightIncrementKg;

  ProgressionSuggestion nextSuggestion({
    required double currentWeightKg,
    required int currentTargetReps,
    required int achievedReps,
  }) {
    return switch (type) {
      ProgressionType.doubleProgression => _nextDoubleProgression(
        currentWeightKg: currentWeightKg,
        currentTargetReps: currentTargetReps,
        achievedReps: achievedReps,
      ),
      _ => throw UnsupportedError('Only double progression is supported in MVP.'),
    };
  }

  ProgressionSuggestion _nextDoubleProgression({
    required double currentWeightKg,
    required int currentTargetReps,
    required int achievedReps,
  }) {
    if (achievedReps < currentTargetReps) {
      return ProgressionSuggestion(
        weightKg: currentWeightKg,
        targetReps: currentTargetReps,
      );
    }

    if (achievedReps >= maxReps) {
      return ProgressionSuggestion(
        weightKg: currentWeightKg + weightIncrementKg,
        targetReps: minReps,
      );
    }

    return ProgressionSuggestion(
      weightKg: currentWeightKg,
      targetReps: (currentTargetReps + repStep).clamp(minReps, maxReps),
    );
  }
}

class ProgressionSuggestion {
  const ProgressionSuggestion({
    required this.weightKg,
    required this.targetReps,
  });

  final double weightKg;
  final int targetReps;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.targetRir,
    required this.restSeconds,
    required this.currentWeightKg,
    required this.currentTargetReps,
    required this.progressionRule,
    this.lastWorkoutResult,
  });

  final String id;
  final String name;
  final String description;
  final int sets;
  final int targetRir;
  final int restSeconds;
  final double currentWeightKg;
  final int currentTargetReps;
  final ProgressionRule progressionRule;
  final ExerciseLog? lastWorkoutResult;
}

class ExerciseLog {
  const ExerciseLog({
    required this.exerciseId,
    required this.completedAt,
    required this.weightKg,
    required this.reps,
    required this.rir,
  });

  final String exerciseId;
  final DateTime completedAt;
  final double weightKg;
  final int reps;
  final int rir;

  Map<String, Object?> toJson() {
    return {
      'exerciseId': exerciseId,
      'completedAt': completedAt.toIso8601String(),
      'weightKg': weightKg,
      'reps': reps,
      'rir': rir,
    };
  }

  factory ExerciseLog.fromJson(Map<String, Object?> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      reps: json['reps'] as int,
      rir: json['rir'] as int,
    );
  }
}

class ExerciseProgressState {
  const ExerciseProgressState({
    required this.exerciseId,
    required this.currentWeightKg,
    required this.currentTargetReps,
  });

  final String exerciseId;
  final double currentWeightKg;
  final int currentTargetReps;

  Map<String, Object?> toJson() {
    return {
      'exerciseId': exerciseId,
      'currentWeightKg': currentWeightKg,
      'currentTargetReps': currentTargetReps,
    };
  }

  factory ExerciseProgressState.fromJson(Map<String, Object?> json) {
    return ExerciseProgressState(
      exerciseId: json['exerciseId'] as String,
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      currentTargetReps: json['currentTargetReps'] as int,
    );
  }
}

class ExerciseProgressionConfig {
  const ExerciseProgressionConfig({
    required this.exerciseId,
    required this.currentWeightKg,
    required this.currentTargetReps,
    required this.minReps,
    required this.maxReps,
    required this.repStep,
    required this.weightIncrementKg,
  });

  final String exerciseId;
  final double currentWeightKg;
  final int currentTargetReps;
  final int minReps;
  final int maxReps;
  final int repStep;
  final double weightIncrementKg;

  ProgressionRule get progressionRule {
    return ProgressionRule(
      type: ProgressionType.doubleProgression,
      minReps: minReps,
      maxReps: maxReps,
      repStep: repStep,
      weightIncrementKg: weightIncrementKg,
    );
  }

  ExerciseProgressState get progressState {
    return ExerciseProgressState(
      exerciseId: exerciseId,
      currentWeightKg: currentWeightKg,
      currentTargetReps: currentTargetReps,
    );
  }

  ExerciseProgressionConfig copyWith({
    double? currentWeightKg,
    int? currentTargetReps,
    int? minReps,
    int? maxReps,
    int? repStep,
    double? weightIncrementKg,
  }) {
    return ExerciseProgressionConfig(
      exerciseId: exerciseId,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      currentTargetReps: currentTargetReps ?? this.currentTargetReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      repStep: repStep ?? this.repStep,
      weightIncrementKg: weightIncrementKg ?? this.weightIncrementKg,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'exerciseId': exerciseId,
      'currentWeightKg': currentWeightKg,
      'currentTargetReps': currentTargetReps,
      'minReps': minReps,
      'maxReps': maxReps,
      'repStep': repStep,
      'weightIncrementKg': weightIncrementKg,
    };
  }

  factory ExerciseProgressionConfig.fromJson(Map<String, Object?> json) {
    return ExerciseProgressionConfig(
      exerciseId: json['exerciseId'] as String,
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      currentTargetReps: json['currentTargetReps'] as int,
      minReps: json['minReps'] as int,
      maxReps: json['maxReps'] as int,
      repStep: json['repStep'] as int,
      weightIncrementKg: (json['weightIncrementKg'] as num).toDouble(),
    );
  }

  factory ExerciseProgressionConfig.fromExercise(Exercise exercise) {
    return ExerciseProgressionConfig(
      exerciseId: exercise.id,
      currentWeightKg: exercise.currentWeightKg,
      currentTargetReps: exercise.currentTargetReps,
      minReps: exercise.progressionRule.minReps,
      maxReps: exercise.progressionRule.maxReps,
      repStep: exercise.progressionRule.repStep,
      weightIncrementKg: exercise.progressionRule.weightIncrementKg,
    );
  }
}
