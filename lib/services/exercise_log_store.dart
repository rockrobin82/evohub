import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/workouts/models.dart';

class ExerciseLogStore {
  ExerciseLogStore(this._preferences);

  static const _logsKey = 'exercise_logs_v1';
  static const _progressStateKey = 'exercise_progress_state_v1';

  final SharedPreferences _preferences;

  Future<List<ExerciseLog>> loadLogs() async {
    final encodedLogs = _preferences.getStringList(_logsKey) ?? const [];
    debugPrint(
      '[ExerciseLogStore] loadLogs key=$_logsKey count=${encodedLogs.length}',
    );
    return encodedLogs
        .map((encodedLog) => jsonDecode(encodedLog) as Map<String, Object?>)
        .map(ExerciseLog.fromJson)
        .toList();
  }

  Future<void> saveLog(ExerciseLog log) async {
    debugPrint(
      '[ExerciseLogStore] saveLog exerciseId=${log.exerciseId} '
      'weightKg=${log.weightKg} reps=${log.reps} rir=${log.rir} '
      'completedAt=${log.completedAt.toIso8601String()} key=$_logsKey',
    );
    final logs = await loadLogs();
    logs.add(log);

    await _preferences.setStringList(
      _logsKey,
      logs.map((item) => jsonEncode(item.toJson())).toList(),
    );
    debugPrint(
      '[ExerciseLogStore] saveLog persisted key=$_logsKey total=${logs.length}',
    );
  }

  Future<ExerciseLog?> latestForExercise(String exerciseId) async {
    final logs = await loadLogs();
    final matchingLogs = logs
        .where((log) => log.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (matchingLogs.isEmpty) {
      debugPrint(
        '[ExerciseLogStore] latestForExercise exerciseId=$exerciseId result=null',
      );
      return null;
    }
    debugPrint(
      '[ExerciseLogStore] latestForExercise exerciseId=$exerciseId '
      'weightKg=${matchingLogs.first.weightKg} reps=${matchingLogs.first.reps} '
      'rir=${matchingLogs.first.rir} completedAt=${matchingLogs.first.completedAt.toIso8601String()}',
    );
    return matchingLogs.first;
  }

  Future<Map<String, ExerciseProgressState>> loadProgressStates() async {
    final encodedStates =
        _preferences.getStringList(_progressStateKey) ?? const [];
    debugPrint(
      '[ExerciseLogStore] loadProgressStates key=$_progressStateKey '
      'count=${encodedStates.length}',
    );
    final states = encodedStates
        .map((encodedState) => jsonDecode(encodedState) as Map<String, Object?>)
        .map(ExerciseProgressState.fromJson);

    return {for (final state in states) state.exerciseId: state};
  }

  Future<ExerciseProgressState?> progressStateForExercise(
    String exerciseId,
  ) async {
    final states = await loadProgressStates();
    return states[exerciseId];
  }

  Future<void> saveProgressState(ExerciseProgressState state) async {
    debugPrint(
      '[ExerciseLogStore] saveProgressState exerciseId=${state.exerciseId} '
      'currentWeightKg=${state.currentWeightKg} '
      'currentTargetReps=${state.currentTargetReps} key=$_progressStateKey',
    );
    final states = await loadProgressStates();
    states[state.exerciseId] = state;

    await _preferences.setStringList(
      _progressStateKey,
      states.values.map((item) => jsonEncode(item.toJson())).toList(),
    );
    debugPrint(
      '[ExerciseLogStore] saveProgressState persisted '
      'key=$_progressStateKey total=${states.length}',
    );
  }
}
