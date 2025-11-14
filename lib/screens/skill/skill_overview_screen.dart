import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../mock/mock_data.dart';
import '../../models/skill.dart';
import '../../widgets/practice_set_card.dart';
import '../../widgets/progress_badge.dart';

class SkillOverviewScreen extends StatelessWidget {
  final Skill skill;
  const SkillOverviewScreen({super.key, required this.skill});

  double _completionForSkill(AppState app) {
    final res = app.results.where((r) => r.skillId == skill.id);
    if (res.isEmpty) return 0;
    return res.map((r) => r.accuracy).fold<double>(0, (a, b) => a + b) / res.length;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final all = setsForSkill(skill.id);
    final recommended = all.take(2).toList();
    final progress = _completionForSkill(app);

    return Scaffold(
      appBar: AppBar(title: Text(skill.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: skill.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill.description),
                  const SizedBox(height: 10),
                  ProgressBadge(value: progress, label: 'Progress'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Recommended for you', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final set in recommended) ...[
              PracticeSetCard(
                set: set,
                skillName: skill.name,
                locked: set.isPremium && !app.isPremium,
                onTap: () {
                  if (set.isPremium && !app.isPremium) {
                    Navigator.pushNamed(context, '/premium');
                  } else {
                    Navigator.pushNamed(context, '/practiceSet', arguments: set.id);
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Text('All practice sets for ${skill.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            for (final set in all) ...[
              PracticeSetCard(
                set: set,
                skillName: skill.name,
                locked: set.isPremium && !app.isPremium,
                onTap: () {
                  if (set.isPremium && !app.isPremium) {
                    Navigator.pushNamed(context, '/premium');
                  } else {
                    Navigator.pushNamed(context, '/practiceSet', arguments: set.id);
                  }
                },
              ),
              const SizedBox(height: 10),
            ]
          ],
        ),
      ),
    );
  }
}

