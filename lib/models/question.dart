import '../core/constants.dart';

class Question {
  final String id;
  final String skillId;
  final String practiceSetId;
  final QuestionType type;
  final String prompt;
  final String? passage;
  final String? audioUrl;
  final List<String>? options; // for MCQ
  final int? correctAnswerIndex; // for practice

  const Question({
    required this.id,
    required this.skillId,
    required this.practiceSetId,
    required this.type,
    required this.prompt,
    this.passage,
    this.audioUrl,
    this.options,
    this.correctAnswerIndex,
  });
}

