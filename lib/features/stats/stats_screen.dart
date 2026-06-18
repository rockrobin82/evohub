import 'package:flutter/material.dart';

import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Statystyki', style: Theme.of(context).textTheme.headlineMedium),
          EvoSpacing.gapSm,
          Text(
            'Podsumowania progresu zostaną zbudowane na bazie historii ćwiczeń.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          EvoSpacing.gapXl,
          const EvoCard(
            child: Text('Statystyki są poza zakresem tego MVP foundation.'),
          ),
        ],
      ),
    );
  }
}
