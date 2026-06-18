import 'package:flutter/material.dart';

import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Historia', style: Theme.of(context).textTheme.headlineMedium),
          EvoSpacing.gapSm,
          Text(
            'Dane treningowe pojawią się tutaj po pierwszych zapisanych seriach.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          EvoSpacing.gapXl,
          const EvoCard(
            child: Text('Historia treningów zostanie dodana w kolejnym kroku.'),
          ),
        ],
      ),
    );
  }
}
