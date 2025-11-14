import 'package:flutter/material.dart';

// Spacing
const double kPageHPad = 16.0;
const double kSectionSpacing = 20.0;
const double kCardRadius = 14.0;

// Refined brand palette — calm, professional teal + gold
const Color kBrandPrimary = Color(0xFF0E7490); // teal 700 base
const Color kBrandPrimaryDark = Color(0xFF0B5E74); // pressed/hover
const Color kBrandAccent = Color(0xFFF0B429); // warm gold for highlights

// Surfaces and neutrals
const Color kSurface = Color(0xFFF6F8FB); // app background
const Color kCard = Colors.white; // card background
const Color kTextPrimary = Color(0xFF111827); // gray-900
const Color kTextSecondary = Color(0xFF4B5563); // gray-600
const Color kSoftDivider = Color(0x1F000000); // subtle divider

// Optional hero gradient for onboarding
const Color kHeroGradStart = Color(0xFF0F9DB5);
const Color kHeroGradEnd = Color(0xFF0B5E74);

enum QuestionType { mcq, gapFill, shortText, essay }

// Exam default durations (minutes)
const int kListeningMinutes = 30;
const int kReadingMinutes = 60;
const int kWritingMinutes = 60;
const int kSpeakingMinutes = 15;
