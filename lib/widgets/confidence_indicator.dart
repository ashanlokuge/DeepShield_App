import 'package:flutter/material.dart';

/// Horizontal, animated confidence bar shown on the result screen.
class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    required this.color,
  });

  /// Value in the range [0.0, 1.0].
  final double confidence;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = confidence.clamp(0.0, 1.0);

    return Semantics(
      label: 'Confidence ${(clamped * 100).toStringAsFixed(1)} percent',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: clamped),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Stack(
              children: [
                Container(
                  height: 14,
                  color: theme.colorScheme.surfaceVariant,
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(height: 14, color: color),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
