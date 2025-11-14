class TestResult {
  final String id;
  final String skillId;
  final String? practiceSetId;
  final int totalQuestions;
  final int correctQuestions;
  final int timeTakenSeconds;
  final DateTime date;

  const TestResult({
    required this.id,
    required this.skillId,
    required this.practiceSetId,
    required this.totalQuestions,
    required this.correctQuestions,
    required this.timeTakenSeconds,
    required this.date,
  });

  double get accuracy => totalQuestions == 0
      ? 0
      : (correctQuestions / totalQuestions).clamp(0, 1);
}

