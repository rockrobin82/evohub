import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evohub/app/evohub_app.dart';
import 'package:evohub/features/workout_session/workout_summary_screen.dart';
import 'package:evohub/features/workouts/models.dart';
import 'package:evohub/features/workouts/sample_workout_plans.dart';

void main() {
  test('double progression uses repStep and achieved reps', () {
    const rule = ProgressionRule(
      type: ProgressionType.doubleProgression,
      minReps: 12,
      maxReps: 18,
      repStep: 2,
      weightIncrementKg: 2.5,
    );

    final missedTarget = rule.nextSuggestion(
      currentWeightKg: 20,
      currentTargetReps: 18,
      achievedReps: 17,
    );
    expect(missedTarget.weightKg, 20);
    expect(missedTarget.targetReps, 18);

    final hitTargetBelowMax = rule.nextSuggestion(
      currentWeightKg: 20,
      currentTargetReps: 14,
      achievedReps: 14,
    );
    expect(hitTargetBelowMax.weightKg, 20);
    expect(hitTargetBelowMax.targetReps, 16);

    final hitMax = rule.nextSuggestion(
      currentWeightKg: 20,
      currentTargetReps: 18,
      achievedReps: 18,
    );
    expect(hitMax.weightKg, 22.5);
    expect(hitMax.targetReps, 12);
  });

  testWidgets('EvoHub dashboard renders sample workout plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EvoHubApp());

    expect(find.text('EvoHub'), findsOneWidget);
    expect(find.text('Twoje plany'), findsOneWidget);
    expect(find.text('FBW Beginner'), findsOneWidget);
    expect(find.text('Trening A'), findsOneWidget);
    expect(find.text('Treningi'), findsOneWidget);
    expect(find.text('Historia'), findsOneWidget);
  });

  testWidgets('bottom navigation opens placeholder tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EvoHubApp());

    await tester.tap(find.text('Statystyki'));
    await tester.pumpAndSettle();

    expect(find.text('Statystyki'), findsWidgets);
    expect(
      find.text('Statystyki są poza zakresem tego MVP foundation.'),
      findsOneWidget,
    );
  });

  testWidgets('dashboard starts workout session and tracks first set', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EvoHubApp());

    final startButton = find.text('Rozpocznij').first;
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.text('FBW Beginner'), findsOneWidget);
    expect(find.text('Dzień A'), findsOneWidget);
    expect(find.text('Start Workout'), findsOneWidget);

    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Exercise 1 of 3'), findsOneWidget);
    expect(find.text('CEL NA DZIŚ'), findsOneWidget);
    expect(find.text('Ostatni trening'), findsOneWidget);
    expect(find.text('Cel na dziś'), findsOneWidget);
    expect(find.text('Następny krok'), findsOneWidget);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('Wpis serii'), findsOneWidget);
    expect(find.text('Zaawansowane'), findsOneWidget);
    expect(find.byKey(const ValueKey('active-set-1')), findsOneWidget);

    await tester.tap(find.text('Seria wykonana'));
    await tester.pumpAndSettle();

    expect(find.text('Przerwa'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('completed-set-1')), findsOneWidget);
  });

  testWidgets('workout summary shows completed totals', (
    WidgetTester tester,
  ) async {
    final plan = sampleWorkoutPlans.first;
    final day = plan.days.first;

    await tester.pumpWidget(
      EvoHubAppTestHost(
        child: WorkoutSummaryScreen(
          plan: plan,
          day: day,
          exercisesCompleted: 3,
          setsCompleted: 12,
          startedAt: DateTime.now().subtract(const Duration(minutes: 42)),
        ),
      ),
    );

    expect(find.text('Świetna robota!'), findsOneWidget);
    expect(find.text('Ćwiczenia ukończone'), findsOneWidget);
    expect(find.text('Serie wykonane'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Powrót do Dashboard'), findsOneWidget);
  });
}

class EvoHubAppTestHost extends StatelessWidget {
  const EvoHubAppTestHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: child);
  }
}
