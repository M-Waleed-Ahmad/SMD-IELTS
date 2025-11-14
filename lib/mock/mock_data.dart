import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/skill.dart';
import '../models/practice_set.dart';
import '../models/question.dart';
import '../models/test_result.dart';

// Skills
const skills = <Skill>[
  Skill(
    id: 'listening',
    name: 'Listening',
    description: 'Practice audio comprehension and note-taking strategies.',
    icon: Icons.headphones,
    color: Color(0xFF4F46E5),
  ),
  Skill(
    id: 'reading',
    name: 'Reading',
    description: 'Sharpen scanning, skimming, and inference skills.',
    icon: Icons.menu_book,
    color: Color(0xFF16A34A),
  ),
  Skill(
    id: 'writing',
    name: 'Writing',
    description: 'Task 1 and Task 2 practice with planning tips.',
    icon: Icons.edit,
    color: Color(0xFFEA580C),
  ),
  Skill(
    id: 'speaking',
    name: 'Speaking',
    description: 'Cue cards and structured prompts to speak confidently.',
    icon: Icons.mic,
    color: Color(0xFF9333EA),
  ),
];

// Practice Sets
final practiceSets = <PracticeSet>[
  // Listening
  PracticeSet(
    id: 'lis_ps1',
    skillId: 'listening',
    title: 'Campus Conversations',
    levelTag: 'Band 6–7',
    questionCount: 6,
    estimatedMinutes: 12,
    isPremium: false,
    shortDescription: 'Short dialogues with everyday topics.',
  ),
  PracticeSet(
    id: 'lis_ps2',
    skillId: 'listening',
    title: 'Lecture Highlights',
    levelTag: 'Band 7+',
    questionCount: 8,
    estimatedMinutes: 15,
    isPremium: true,
    shortDescription: 'Identify key ideas from mini-lectures.',
  ),
  PracticeSet(
    id: 'lis_ps3',
    skillId: 'listening',
    title: 'Service Calls',
    levelTag: 'Band 5–6',
    questionCount: 5,
    estimatedMinutes: 10,
    isPremium: false,
    shortDescription: 'Customer support and scheduling details.',
  ),

  // Reading
  PracticeSet(
    id: 'read_ps1',
    skillId: 'reading',
    title: 'True/False/Not Given',
    levelTag: 'Band 6–7',
    questionCount: 7,
    estimatedMinutes: 12,
    isPremium: false,
    shortDescription: 'Practice popular IELTS reading question type.',
  ),
  PracticeSet(
    id: 'read_ps2',
    skillId: 'reading',
    title: 'Matching Headings',
    levelTag: 'Band 7+',
    questionCount: 8,
    estimatedMinutes: 15,
    isPremium: true,
    shortDescription: 'Find the best headings for paragraphs.',
  ),
  PracticeSet(
    id: 'read_ps3',
    skillId: 'reading',
    title: 'Short Passages',
    levelTag: 'Band 5–6',
    questionCount: 6,
    estimatedMinutes: 10,
    isPremium: false,
    shortDescription: 'Quick comprehension drills.',
  ),

  // Writing
  PracticeSet(
    id: 'wri_ps1',
    skillId: 'writing',
    title: 'Task 1 – Graph',
    levelTag: 'Band 6–7',
    questionCount: 1,
    estimatedMinutes: 20,
    isPremium: false,
    shortDescription: 'Summarize visual information in 150+ words.',
  ),
  PracticeSet(
    id: 'wri_ps2',
    skillId: 'writing',
    title: 'Task 2 – Opinion Essay',
    levelTag: 'Band 7+',
    questionCount: 1,
    estimatedMinutes: 30,
    isPremium: true,
    shortDescription: 'Present a clear position and examples.',
  ),

  // Speaking
  PracticeSet(
    id: 'spk_ps1',
    skillId: 'speaking',
    title: 'Cue Cards – Daily Life',
    levelTag: 'Band 5–6',
    questionCount: 4,
    estimatedMinutes: 10,
    isPremium: false,
    shortDescription: 'Warm up with familiar topics.',
  ),
  PracticeSet(
    id: 'spk_ps2',
    skillId: 'speaking',
    title: 'Discussion Topics',
    levelTag: 'Band 7+',
    questionCount: 4,
    estimatedMinutes: 12,
    isPremium: true,
    shortDescription: 'Practice giving opinions and reasons.',
  ),
];

// Questions
final questions = <Question>[
  // Listening – mostly MCQ with audio placeholder
  Question(
    id: 'q1',
    skillId: 'listening',
    practiceSetId: 'lis_ps1',
    type: QuestionType.mcq,
    prompt: 'What time will the meeting start?',
    audioUrl: 'audio_placeholder.mp3',
    options: ['9:00', '9:30', '10:00'],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'q2',
    skillId: 'listening',
    practiceSetId: 'lis_ps1',
    type: QuestionType.mcq,
    prompt: 'Where should the students meet?',
    audioUrl: 'audio_placeholder.mp3',
    options: ['Library', 'Cafeteria', 'Hall A'],
    correctAnswerIndex: 0,
  ),

  // Reading – with small passage
  Question(
    id: 'q3',
    skillId: 'reading',
    practiceSetId: 'read_ps1',
    type: QuestionType.mcq,
    prompt:
        'According to the passage, the new policy primarily aims to…',
    passage:
        'The city introduced a bike-sharing scheme to reduce traffic congestion and improve air quality. Early results show…',
    options: [
      'Increase car usage',
      'Reduce pollution and traffic',
      'Ban private vehicles'
    ],
    correctAnswerIndex: 1,
  ),
  Question(
    id: 'q4',
    skillId: 'reading',
    practiceSetId: 'read_ps1',
    type: QuestionType.shortText,
    prompt: 'Write one benefit mentioned for bike-sharing.',
    passage: '…reduce traffic congestion and improve air quality…',
  ),

  // Writing – Essay
  Question(
    id: 'q5',
    skillId: 'writing',
    practiceSetId: 'wri_ps1',
    type: QuestionType.essay,
    prompt:
        'Summarize the main trends shown in the chart about internet usage between 2000 and 2020.',
  ),
  Question(
    id: 'q6',
    skillId: 'writing',
    practiceSetId: 'wri_ps2',
    type: QuestionType.essay,
    prompt:
        'Some people think government should invest more in public transportation than in building new roads. To what extent do you agree or disagree?',
  ),

  // Speaking – Prompts
  Question(
    id: 'q7',
    skillId: 'speaking',
    practiceSetId: 'spk_ps1',
    type: QuestionType.shortText,
    prompt: 'Describe your favorite place to study and why it suits you.',
  ),
  Question(
    id: 'q8',
    skillId: 'speaking',
    practiceSetId: 'spk_ps1',
    type: QuestionType.shortText,
    prompt: 'Talk about a memorable trip you took recently.',
  ),
];

// Basic recent results (mock)
final recentResults = <TestResult>[
  TestResult(
    id: 'r1',
    skillId: 'reading',
    practiceSetId: 'read_ps3',
    totalQuestions: 6,
    correctQuestions: 4,
    timeTakenSeconds: 540,
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TestResult(
    id: 'r2',
    skillId: 'listening',
    practiceSetId: 'lis_ps3',
    totalQuestions: 5,
    correctQuestions: 3,
    timeTakenSeconds: 480,
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

List<PracticeSet> setsForSkill(String skillId) =>
    practiceSets.where((s) => s.skillId == skillId).toList();

List<Question> questionsForPracticeSet(String practiceSetId) =>
    questions.where((q) => q.practiceSetId == practiceSetId).toList();

