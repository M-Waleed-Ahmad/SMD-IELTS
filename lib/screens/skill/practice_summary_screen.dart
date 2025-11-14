import 'package:flutter/material.dart';
import '../../mock/mock_data.dart';
import '../../models/test_result.dart';
import '../../core/constants.dart';

class PracticeSummaryScreen extends StatelessWidget {
  final TestResult result; // includes skillId, practiceSetId, totals
  const PracticeSummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Try to find matching skill & set in mock_data,
    // but don't crash if they aren't there (backend IDs).
    final skillMatches = skills.where((s) => s.id == result.skillId);
    final setMatches = practiceSets.where((p) => p.id == result.practiceSetId);

    final skill = skillMatches.isNotEmpty ? skillMatches.first : null;
    final set = setMatches.isNotEmpty ? setMatches.first : null;

    final titleText = [
      if (skill != null) skill.name,
      if (set != null) set.title,
    ].join(' • ');

    final headerTitle =
        titleText.isNotEmpty ? titleText : 'Practice summary';

    final subtitleText = skill != null
        ? 'Nice work! You finished this ${skill.name} practice set.'
        : 'Nice work! You finished this practice set.';

    // Defensive in case time is null or 0
    final total = result.totalQuestions;
    final correct = result.correctQuestions;
    final minutes = (result.timeTakenSeconds ?? 0) / 60;
    final timeLabel =
        minutes > 0 ? '${minutes.round()} min' : '${result.timeTakenSeconds ?? 0}s';

    return Scaffold(
      appBar: AppBar(title: const Text('Practice summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: kBrandAccent.withOpacity(0.2),
                    child: const Icon(
                      Icons.check_rounded,
                      color: kBrandAccent,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  headerTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _stat(
                          'Total',
                          total != null ? total.toString() : '-',
                        ),
                      ),
                      Expanded(
                        child: _stat(
                          'Correct',
                          correct != null ? correct.toString() : '-',
                        ),
                      ),
                      Expanded(
                        child: _stat('Time', timeLabel),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(subtitleText),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // In this MVP, just navigate back to the shell (practice tab)
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/shell'),
                        );
                      },
                      child: const Text('Back to practice'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // MVP: just go back; review flow can be added later
                        Navigator.pop(context);
                      },
                      child: const Text('Review questions'),
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

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
