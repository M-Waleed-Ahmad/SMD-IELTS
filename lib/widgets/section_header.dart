import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  const SectionHeader({super.key, required this.title, this.icon, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          if (onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel ?? 'See all')),
        ],
      ),
    );
  }
}
