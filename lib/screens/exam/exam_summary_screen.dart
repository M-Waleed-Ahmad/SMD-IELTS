import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../mock/mock_data.dart';
import '../../models/test_result.dart';

class ExamSummaryScreen extends StatelessWidget {
  final List<TestResult> results;
  const ExamSummaryScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    // store into global recent results
    for (final r in results) {
      app.addResult(r);
    }
    final totalSeconds = results.fold<int>(0, (a, b) => a + b.timeTakenSeconds);
    final totalObjective = results.where((r) => r.totalQuestions > 0).toList();
    final correct = totalObjective.fold<int>(0, (a, b) => a + b.correctQuestions);
    final total = totalObjective.fold<int>(0, (a, b) => a + b.totalQuestions);

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 32, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Full exam simulation completed', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text('Time spent: ${(totalSeconds / 60).round()} min • Performance: ${total == 0 ? '—' : '$correct/$total correct'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final r = results[index];
                    final skill = skills.firstWhere((s) => s.id == r.skillId);
                    final attempted = r.totalQuestions; // in this MVP, attempted == total
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: skill.color.withOpacity(0.15), child: Icon(skill.icon, color: skill.color)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(skill.name, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Time: ${(r.timeTakenSeconds / 60).round()} min • ${r.totalQuestions == 0 ? 'Completed' : 'Correct ${r.correctQuestions}/${r.totalQuestions}'}'),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Go to Practice'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text('Try another simulation'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
