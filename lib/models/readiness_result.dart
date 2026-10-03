import 'package:flutter/material.dart';

import 'assessment.dart';

/// One line of the score breakdown (e.g. "Mock test performance - 58%").
class ComponentScore {
  final String id;
  final String label;
  final double value; // 0-100
  final double weight; // 0.0 - 1.0
  final IconData icon;

  const ComponentScore({
    required this.id,
    required this.label,
    required this.value,
    required this.weight,
    required this.icon,
  });
}

/// Everything the Results screen needs to display.
class ReadinessResult {
  final double score; // 0-100
  final String category;
  final String summary;
  final AssessmentInput input;
  final List<ComponentScore> components;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;

  const ReadinessResult({
    required this.score,
    required this.category,
    required this.summary,
    required this.input,
    required this.components,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
  });
}
