import 'package:flutter/material.dart';

import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
          EvoSpacing.gapSm,
          Text(
            'Ustawienia użytkownika pojawią się tutaj bez dodawania auth ani backendu.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          EvoSpacing.gapXl,
          const EvoCard(child: Text('Profil i ustawienia są placeholderem.')),
        ],
      ),
    );
  }
}
