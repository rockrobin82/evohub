import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/design_tokens.dart';
import '../../shared/spacing.dart';
import '../../widgets/evo_card.dart';

class RestTimerScreen extends StatefulWidget {
  const RestTimerScreen({super.key, required this.seconds});

  final int seconds;

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Przerwa')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              EvoSpacing.gapXl,
              Text(
                _isFinished ? 'Przerwa zakończona' : 'Następna seria',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              _TimerRing(
                progress: _remainingSeconds / widget.seconds,
                label: _formatTime(_remainingSeconds),
                isFinished: _isFinished,
              ),
              const Spacer(),
              EvoCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _TimerButton(
                        label: '-30 sec',
                        onPressed: _isFinished
                            ? null
                            : () => _adjustTime(-30),
                      ),
                    ),
                    const SizedBox(width: EvoSpacing.sm),
                    Expanded(
                      child: _TimerButton(
                        label: '+30 sec',
                        onPressed: _isFinished ? null : () => _adjustTime(30),
                      ),
                    ),
                    const SizedBox(width: EvoSpacing.sm),
                    Expanded(
                      child: _TimerButton(
                        label: 'Skip',
                        onPressed: _isFinished ? null : _skip,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tick() {
    if (_remainingSeconds <= 1) {
      _finish();
      return;
    }

    setState(() => _remainingSeconds -= 1);
  }

  void _adjustTime(int deltaSeconds) {
    setState(() {
      _remainingSeconds = (_remainingSeconds + deltaSeconds).clamp(0, 3600);
    });

    if (_remainingSeconds == 0) {
      _finish();
    }
  }

  void _finish() {
    if (_isFinished) return;

    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isFinished = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _skip() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final paddedMinutes = minutes.toString().padLeft(2, '0');
    final paddedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$paddedMinutes:$paddedSeconds';
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.label,
    required this.isFinished,
  });

  final double progress;
  final String label;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 12,
              backgroundColor: EvoColors.surfaceHigh,
              color: isFinished ? EvoColors.success : EvoColors.primary,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: EvoColors.textPrimary,
          side: const BorderSide(color: EvoColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EvoRadii.small),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
