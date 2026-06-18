import 'package:flutter/material.dart';

import '../shared/design_tokens.dart';

class EvoHubTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: EvoColors.primary,
      onPrimary: EvoColors.onPrimary,
      surface: EvoColors.surface,
      onSurface: EvoColors.textPrimary,
      onSurfaceVariant: EvoColors.textSecondary,
      error: Color(0xFFF85149),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EvoColors.scaffold,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: EvoColors.scaffold,
        foregroundColor: EvoColors.textPrimary,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: EvoColors.primary,
          foregroundColor: EvoColors.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EvoRadii.small),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: EvoColors.surface,
        indicatorColor: EvoColors.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            color: isSelected ? EvoColors.primary : EvoColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? EvoColors.primary : EvoColors.textSecondary,
            size: 22,
          );
        }),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: EvoColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: EvoColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: EvoColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: EvoColors.textPrimary),
        bodySmall: TextStyle(color: EvoColors.textSecondary),
        labelMedium: TextStyle(
          color: EvoColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
