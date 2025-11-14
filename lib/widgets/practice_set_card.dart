import 'package:flutter/material.dart';
import '../models/practice_set.dart';
import 'premium_lock_overlay.dart';

class PracticeSetCard extends StatelessWidget {
  final PracticeSet set;
  final String skillName;
  final bool locked;
  final VoidCallback onTap;
  const PracticeSetCard({super.key, required this.set, required this.skillName, required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitle = '$skillName • ${set.levelTag}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(set.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.help_outline, size: 16),
                      const SizedBox(width: 6),
                      Text('${set.questionCount} questions'),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 6),
                      Text('${set.estimatedMinutes} min'),
                      const Spacer(),
                      if (set.isPremium)
                        Icon(locked ? Icons.lock : Icons.workspace_premium,
                            color: locked ? Colors.amber : Colors.green, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PremiumLockOverlay(locked: locked),
        ],
      ),
    );
  }
}

