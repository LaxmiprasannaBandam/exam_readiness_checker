import 'package:flutter/material.dart';

import '../models/assessment.dart';
import '../models/readiness_result.dart';
import '../models/subject.dart';

/// Calculates the Readiness Score.
///
/// IMPORTANT: this is a simple, transparent study-planning formula made for
/// this app. It is NOT a professional, scientific or predictive assessment.
///
///   Readiness Score =
///       30% syllabus completion
///     + 25% mock test score
///     + 20% practice questions (capped at [targetQuestions])
///     + 15% revision sessions  (capped at [targetRevisions])
///     + 10% confidence (1-5 converted to a percentage)
class ReadinessCalculator {
  // ---- Weights (they add up to 1.0) ----
  static const double syllabusWeight = 0.30;
  static const double mockWeight = 0.25;
  static const double practiceWeight = 0.20;
  static const double revisionWeight = 0.15;
  static const double confidenceWeight = 0.10;

  // ---- Targets used to "normalise" unlimited numbers into 0-100 ----
  /// Solving 300 questions (or more) counts as 100% for the practice part.
  static const int targetQuestions = 300;

  /// Completing 10 revision sessions (or more) counts as 100%.
  static const int targetRevisions = 10;

  static double _cap(double v) => v.clamp(0.0, 100.0).toDouble();

  /// Normalised 0-100 value for practice questions.
  /// Example: 150 questions -> 150 / 300 = 50%.  900 questions -> still 100%.
  static double practiceScore(int questions) =>
      _cap(questions / targetQuestions * 100.0);

  /// Normalised 0-100 value for revision sessions.
  static double revisionScore(int revisions) =>
      _cap(revisions / targetRevisions * 100.0);

  /// Confidence 1-5 -> 20%-100%.
  static double confidenceScore(int confidence) =>
      _cap(confidence / 5.0 * 100.0);

  /// The final 0-100 readiness score.
  static double calculateScore(AssessmentInput i) {
    return _cap(i.syllabus) * syllabusWeight +
        _cap(i.mockScore) * mockWeight +
        practiceScore(i.questions) * practiceWeight +
        revisionScore(i.revisions) * revisionWeight +
        confidenceScore(i.confidence) * confidenceWeight;
  }

  /// Simple app-generated preparation level for a score.
  static String categoryFor(double score) {
    final s = score.round();
    if (s >= 80) return 'Highly Prepared';
    if (s >= 60) return 'Moderately Prepared';
    if (s >= 40) return 'Needs More Preparation';
    return 'Early Preparation Stage';
  }

  /// The five rows shown in the "Score breakdown" card.
  static List<ComponentScore> buildComponents(AssessmentInput i) {
    return [
      ComponentScore(
        id: 'syllabus',
        label: 'Syllabus completion',
        value: _cap(i.syllabus),
        weight: syllabusWeight,
        icon: Icons.menu_book_rounded,
      ),
      ComponentScore(
        id: 'mock',
        label: 'Mock test performance',
        value: _cap(i.mockScore),
        weight: mockWeight,
        icon: Icons.quiz_rounded,
      ),
      ComponentScore(
        id: 'practice',
        label: 'Practice questions',
        value: practiceScore(i.questions),
        weight: practiceWeight,
        icon: Icons.edit_note_rounded,
      ),
      ComponentScore(
        id: 'revision',
        label: 'Revision consistency',
        value: revisionScore(i.revisions),
        weight: revisionWeight,
        icon: Icons.replay_rounded,
      ),
      ComponentScore(
        id: 'confidence',
        label: 'Confidence',
        value: confidenceScore(i.confidence),
        weight: confidenceWeight,
        icon: Icons.emoji_events_rounded,
      ),
    ];
  }

  /// Builds the complete result: score, category, strengths, weak areas,
  /// and suggestions. Everything is simple if/else logic - no AI involved.
  static ReadinessResult analyse(AssessmentInput input, List<Subject> subjects) {
    final components = buildComponents(input);
    final score = calculateScore(input);

    final strengths = <String>[];
    final weaknesses = <String>[];
    final suggestions = <String>[];

    for (final c in components) {
      if (c.value >= 70) strengths.add(_strengthText(c, input));
      if (c.value < 50) {
        weaknesses.add(_weakText(c, input));
        suggestions.add(_suggestionText(c, input));
      }
    }

    // Subject-based suggestion: point at the weakest subject.
    if (subjects.isNotEmpty) {
      final sorted = [...subjects]
        ..sort((a, b) => a.preparationScore.compareTo(b.preparationScore));
      final weakest = sorted.first;
      if (weakest.preparationScore < 70) {
        suggestions.add(
            'Give extra time to ${weakest.name} - it is your weakest subject right now.');
      }
    }

    if (strengths.isEmpty) {
      strengths.add('You have started tracking your preparation - that is a good first step.');
    }
    if (weaknesses.isEmpty) {
      weaknesses.add('No major weak areas found. Keep practising to stay sharp.');
    }
    if (suggestions.isEmpty) {
      suggestions.add(
          'Keep your routine going: one mock test and one revision session every few days.');
    }

    return ReadinessResult(
      score: score,
      category: categoryFor(score),
      summary: _summary(components),
      input: input,
      components: components,
      strengths: strengths,
      weaknesses: weaknesses,
      suggestions: suggestions,
    );
  }

  // ---------- text helpers ----------

  static String _summary(List<ComponentScore> components) {
    var strongest = components.first;
    var weakest = components.first;
    for (final c in components) {
      if (c.value > strongest.value) strongest = c;
      if (c.value < weakest.value) weakest = c;
    }
    final s = strongest.label.toLowerCase();
    final w = weakest.label.toLowerCase();

    if (weakest.value >= 70) {
      return 'Your preparation looks balanced across all areas. Keep it up!';
    }
    if (strongest.value >= 70 && weakest.value < 60) {
      return 'Your $s is strong, but your $w needs more practice.';
    }
    if (weakest.value < 50) {
      return 'Focus on your $w first - it is holding your score back the most.';
    }
    return 'You are making steady progress. A little more work on your $w will help.';
  }

  static String _strengthText(ComponentScore c, AssessmentInput i) {
    switch (c.id) {
      case 'syllabus':
        return 'Syllabus coverage is strong (${i.syllabus.round()}% completed).';
      case 'mock':
        return 'Your mock-test score is solid (${i.mockScore.round()}%).';
      case 'practice':
        return 'You have solved plenty of practice questions (${i.questions}).';
      case 'revision':
        return 'You revise regularly (${i.revisions} sessions completed).';
      default:
        return 'You feel confident about the exam (${i.confidence}/5).';
    }
  }

  static String _weakText(ComponentScore c, AssessmentInput i) {
    switch (c.id) {
      case 'syllabus':
        return 'Only ${i.syllabus.round()}% of the syllabus is completed.';
      case 'mock':
        return 'Mock-test score is low (${i.mockScore.round()}%).';
      case 'practice':
        return 'Few practice questions solved so far (${i.questions}).';
      case 'revision':
        return 'Not enough revision sessions yet (${i.revisions}).';
      default:
        return 'Confidence is low (${i.confidence}/5).';
    }
  }

  static String _suggestionText(ComponentScore c, AssessmentInput i) {
    switch (c.id) {
      case 'syllabus':
        return 'Plan daily slots to finish the remaining ${(100 - i.syllabus).round()}% of the syllabus.';
      case 'mock':
        return 'Take a timed mock test and review every mistake - it carries 25% of your score.';
      case 'practice':
        return 'Solve more practice questions. Aim for about $targetQuestions in total (you are at ${i.questions}).';
      case 'revision':
        return 'Schedule short revision sessions. Aim for $targetRevisions in total (you are at ${i.revisions}).';
      default:
        return 'Re-attempt topics you already know well to build confidence.';
    }
  }
}
