import 'package:flutter/material.dart';

import '../models/assessment.dart';
import '../models/exam.dart';
import '../models/subject.dart';

class PlanTask {
  final String text;
  final IconData icon;
  const PlanTask(this.text, this.icon);
}

class PlanDay {
  final String title;
  final List<PlanTask> tasks;
  const PlanDay(this.title, this.tasks);
}

/// Builds a short study plan using simple if/else rules (no AI, no internet).
class StudyPlanGenerator {
  static List<PlanDay> generate({
    required List<Subject> subjects,
    required AssessmentInput input,
    Exam? exam,
  }) {
    if (subjects.isEmpty) return [];

    // Weakest subject first.
    final sorted = [...subjects]
      ..sort((a, b) => a.preparationScore.compareTo(b.preparationScore));
    final weakest = sorted.first;

    // ---- Today ----
    final today = <PlanTask>[
      PlanTask('Revise ${weakest.name} (your weakest subject)', Icons.menu_book_rounded),
      PlanTask(
        'Solve ${weakest.questionsPracticed < 100 ? 20 : 10} practice questions from ${weakest.name}',
        Icons.edit_note_rounded,
      ),
    ];
    if (sorted.length > 1 && sorted[1].preparationScore < 60) {
      today.add(PlanTask('Skim your notes of ${sorted[1].name} for 30 minutes', Icons.timer_rounded));
    }

    // ---- Tomorrow ----
    final tomorrow = <PlanTask>[];
    if (input.mockScore < 60) {
      tomorrow.add(const PlanTask('Take one full timed mock test', Icons.quiz_rounded));
      tomorrow.add(const PlanTask('Review every incorrect answer and note why you missed it', Icons.fact_check_rounded));
    } else {
      tomorrow.add(const PlanTask('Take a timed mock test to stay exam-ready', Icons.quiz_rounded));
      tomorrow.add(const PlanTask('Review any incorrect answers', Icons.fact_check_rounded));
    }
    if (input.confidence <= 2) {
      tomorrow.add(const PlanTask('Re-attempt questions you solved correctly before, to build confidence', Icons.emoji_events_rounded));
    }

    // ---- Day 3 ----
    final day3 = <PlanTask>[];
    final incomplete = sorted.where((s) => s.completion < 70).take(2).toList();
    for (final s in incomplete) {
      day3.add(PlanTask(
        'Finish remaining topics in ${s.name} (currently ${s.completion.round()}%)',
        Icons.checklist_rounded,
      ));
    }
    if (incomplete.isEmpty) {
      day3.add(const PlanTask('Do a quick revision round of every subject', Icons.replay_rounded));
    }
    if (input.revisions < 6) {
      day3.add(const PlanTask('Complete one full revision session across all subjects', Icons.replay_rounded));
    }

    // ---- Later ----
    final later = <PlanTask>[
      const PlanTask('Repeat the cycle: mock test, review mistakes, revise weak topics', Icons.loop_rounded),
      const PlanTask('Keep the day before the exam light: quick notes, rest and good sleep', Icons.bedtime_rounded),
    ];

    return [
      PlanDay('Today', today),
      PlanDay('Tomorrow', tomorrow),
      PlanDay('Day 3', day3),
      PlanDay('Until the exam', later),
    ];
  }
}
