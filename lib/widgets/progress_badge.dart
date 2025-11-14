import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  final double value; // 0..1
  final String? label;
  const ProgressBadge({super.key, required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label ?? '${(value * 100).round()}%', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

