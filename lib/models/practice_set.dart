class PracticeSet {
  final String id;
  final String skillId;
  final String title;
  final String levelTag; // e.g. Band 6–7
  final int questionCount;
  final int estimatedMinutes;
  final bool isPremium;
  final String shortDescription;

  const PracticeSet({
    required this.id,
    required this.skillId,
    required this.title,
    required this.levelTag,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.isPremium,
    required this.shortDescription,
  });
}

