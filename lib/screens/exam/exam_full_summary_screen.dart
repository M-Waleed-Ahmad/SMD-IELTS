import 'package:flutter/material.dart';

class ExamFullSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> summary;
  const ExamFullSummaryScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final sections = List<Map<String, dynamic>>.from(summary['sections'] as List);
    final exam = summary['exam_session'] as Map<String, dynamic>;
    final totalTime = exam['total_time_seconds'];
    return Scaffold(
      appBar: AppBar(title: const Text('Full Exam Summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_rounded, color: Colors.green),
                  title: const Text('Exam completed'),
                  subtitle: Text('Total time: ${((totalTime ?? 0) / 60).round()} min'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = sections[i];
                    return Card(
                      child: ExpansionTile(
                        title: Text((s['skill_slug'] as String).toUpperCase()),
                        subtitle: Text('Time ${(s['time_taken_seconds'] ?? 0) / 60 ~/ 1} min • ${s['total_questions'] ?? 0} Q • ${(s['correct_questions'] ?? 0)} correct'),
                        children: [
                          if (s['answers'] != null)
                            ...List<Widget>.from((s['answers'] as List).map((a) => ListTile(
                                  title: Text(a['prompt'] ?? ''),
                                  subtitle: Text('Your answer: ${a['user_answer'] ?? '-'}'),
                                  trailing: Icon(a['is_correct'] == true ? Icons.check_circle : Icons.cancel, color: a['is_correct'] == true ? Colors.green : Colors.red),
                                ))),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

