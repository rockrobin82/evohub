import 'package:flutter/material.dart';

import '../shared/design_tokens.dart';

class EvoCard extends StatelessWidget {
  const EvoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: EvoColors.surface,
        border: Border.all(color: EvoColors.border),
        borderRadius: BorderRadius.circular(EvoRadii.medium),
      ),
      child: child,
    );
  }
}
