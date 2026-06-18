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
}
