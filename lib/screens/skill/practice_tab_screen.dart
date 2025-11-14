import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../models/practice_set.dart';
import '../../core/api_client.dart';
import '../../widgets/practice_set_card.dart';

class PracticeTabScreen extends StatefulWidget {
  const PracticeTabScreen({super.key});

  @override
  State<PracticeTabScreen> createState() => _PracticeTabScreenState();
}

class _PracticeTabScreenState extends State<PracticeTabScreen> {
  final _api = ApiClient();

  String? selectedSkillSlug;
  late Future<List<dynamic>> _skillsFut;
  Future<List<dynamic>>? _setsFut;
  List<dynamic>? _cachedSets; // local cache

  @override
  void initState() {
    super.initState();
    _skillsFut = _api.getSkills();
  }

  Future<void> _loadSets(String slug, {bool force = false}) async {
    if (!force && _cachedSets != null && selectedSkillSlug == slug) return;
    final sets = await _api.getPracticeSetsForSkill(slug);
    if (!mounted) return;
    setState(() {
      selectedSkillSlug = slug;
      _cachedSets = sets;
      _setsFut = Future.value(sets);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);

    return Column(
      children: [
        FutureBuilder<List<dynamic>>(
          future: _skillsFut,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load skills: ${snap.error}'),
              );
            }

            final skills = snap.data ?? [];
            if (skills.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No skills found'),
              );
            }

            // Initialize first skill only once
            if (selectedSkillSlug == null) {
              selectedSkillSlug = skills.first['slug'];
              _loadSets(selectedSkillSlug!);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final s in skills)
                    ChoiceChip(
                      label: Text(s['name']),
                      selected: selectedSkillSlug == s['slug'],
                      onSelected: (_) => _loadSets(s['slug'], force: true),
                    ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _setsFut,
            builder: (context, snap) {
              final sets = _cachedSets ?? snap.data;

              if (snap.connectionState == ConnectionState.waiting && sets == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load practice sets'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedSkillSlug != null) {
                            _loadSets(selectedSkillSlug!, force: true);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (sets == null || sets.isEmpty) {
                return const Center(child: Text('No practice sets available.'));
              }

              return RefreshIndicator(
                onRefresh: () => _loadSets(selectedSkillSlug!, force: true),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final set = sets[index];
                    final locked = (set['is_premium'] as bool) && !app.isPremium;

                    final psModel = PracticeSet(
                      id: set['id'],
                      skillId: selectedSkillSlug ?? 'skill',
                      title: set['title'],
                      levelTag: set['level_tag'] ?? '',
                      questionCount: set['question_count'] ?? 0,
                      estimatedMinutes: set['estimated_minutes'] ?? 0,
                      isPremium: set['is_premium'] ?? false,
                      shortDescription: set['short_description'] ?? '',
                    );

                    return PracticeSetCard(
                      set: psModel,
                      skillName: selectedSkillSlug ?? 'Skill',
                      locked: locked,
                      onTap: () {
                        if (locked) {
                          Navigator.pushNamed(context, '/premium');
                        } else {
                          Navigator.pushNamed(context, '/practiceSet', arguments: psModel.id);
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
