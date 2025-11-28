import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/api_client.dart';
import '../../models/skill.dart';
import '../../models/practice_set.dart';
import '../../widgets/practice_set_card.dart';
import '../../widgets/progress_badge.dart';

class SkillOverviewScreen extends StatefulWidget {
  final Skill skill;
  const SkillOverviewScreen({super.key, required this.skill});

  @override
  State<SkillOverviewScreen> createState() => _SkillOverviewScreenState();
}

class _SkillOverviewScreenState extends State<SkillOverviewScreen> {
  final _api = ApiClient();
  late Future<List<PracticeSet>> _setsFuture;

  @override
  void initState() {
    super.initState();
    _setsFuture = _loadSets();
  }

  Future<List<PracticeSet>> _loadSets() async {
    // assuming skill.id is the slug used in /api/skills/<slug>/practice-sets
    final raw = await _api.getPracticeSetsForSkill(widget.skill.id);

    return raw.map<PracticeSet>((set) {
      return PracticeSet(
        id: set['id'],
        skillId: widget.skill.id,
        title: set['title'] ?? '',
        levelTag: set['level_tag'] ?? '',
        questionCount: set['question_count'] ?? 0,
        estimatedMinutes: set['estimated_minutes'] ?? 0,
        isPremium: set['is_premium'] ?? false,
        shortDescription: set['short_description'] ?? '',
      );
    }).toList();
  }

  double _completionForSkill(AppState app) {
    final res = app.results.where((r) => r.skillId == widget.skill.id);
    if (res.isEmpty) return 0;
    return res
            .map((r) => r.accuracy)
            .fold<double>(0, (a, b) => a + b) /
        res.length;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.skill.name)),
      body: SafeArea(
        child: FutureBuilder<List<PracticeSet>>(
          future: _setsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load practice sets'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _setsFuture = _loadSets();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final sets = snapshot.data ?? [];
            final recommended = sets.take(2).toList();
            final progress = _completionForSkill(app);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.skill.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.skill.description),
                      const SizedBox(height: 10),
                      ProgressBadge(value: progress, label: 'Progress'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Recommended for you',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                for (final set in recommended) ...[
                  PracticeSetCard(
                    set: set,
                    skillName: widget.skill.name,
                    locked: set.isPremium && !app.isPremium,
                    onTap: () {
                      if (set.isPremium && !app.isPremium) {
                        Navigator.pushNamed(context, '/premium');
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/practiceSet',
                          arguments: set.id,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                Text(
                  'All practice sets for ${widget.skill.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                for (final set in sets) ...[
                  PracticeSetCard(
                    set: set,
                    skillName: widget.skill.name,
                    locked: set.isPremium && !app.isPremium,
                    onTap: () {
                      if (set.isPremium && !app.isPremium) {
                        Navigator.pushNamed(context, '/premium');
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/practiceSet',
                          arguments: set.id,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
