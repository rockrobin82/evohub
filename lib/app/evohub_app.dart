import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme.dart';

class EvoHubApp extends StatelessWidget {
  const EvoHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvoHub',
      debugShowCheckedModeBanner: false,
      theme: EvoHubTheme.dark,
      home: const AppShell(),
    );
  }
}
