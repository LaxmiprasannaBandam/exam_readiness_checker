import 'package:flutter/material.dart';

import '../models/exam.dart';
import '../services/readiness_calculator.dart';
import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/score_ring.dart';
import '../widgets/stat_card.dart';

/// Dashboard: greeting, exam card, readiness score, quick stats, buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final input = state.input;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // ---- Greeting ----
            Text('Hello, Student',
                style: TextStyle(
                    fontSize: 15, color: onSurface.withOpacity(0.6))),
            const SizedBox(height: 4),
            const Text(
              'Ready to check your preparation?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),

            // ---- Demo-data banner ----
            if (state.isSampleData) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.info, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are viewing demo data. Edit your exam and subjects to make it yours.',
                        style: TextStyle(
                            fontSize: 13, color: onSurface.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ---- Exam card ----
            _ExamCard(exam: state.exam, subjectCount: state.subjects.length),
            const SizedBox(height: 16),

            // ---- Readiness card ----
            _ReadinessCard(
              score: state.latestScore,
              lastCheck: state.latestCheckDate,
            ),
            const SizedBox(height: 22),

            // ---- Quick stats ----
            const Text('Quick stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Syllabus completed',
                    value: '${input.syllabus.round()}%',
                    color: AppColors.seed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.quiz_rounded,
                    label: 'Mock test score',
                    value: '${input.mockScore.round()}%',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.edit_note_rounded,
                    label: 'Questions solved',
                    value: '${input.questions}',
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.replay_rounded,
                    label: 'Revision sessions',
                    value: '${input.revisions}',
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Buttons ----
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.assessment),
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Check My Readiness'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              // Switch to the "Progress" tab.
              onPressed: () => AppScope.read(context).setTab(1),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('My Progress'),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
              icon: const Icon(Icons.history_rounded),
              label: const Text('View progress history'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.subjectCount});

  final Exam? exam;
  final int subjectCount;

  @override
  Widget build(BuildContext context) {
    if (exam == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No upcoming exam yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Add your exam and subjects to start tracking your preparation.',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.65)),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.setup),
              child: const Text('Set up my exam'),
            ),
          ],
        ),
      );
    }

    final e = exam!;
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.seed, AppColors.violet],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Upcoming exam',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit exam',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.setup),
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
              ),
            ],
          ),
          Text(
            e.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(DateHelper.format(e.date),
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              const Icon(Icons.menu_book_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text('$subjectCount subjects',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              e.daysLeftLabel,
              style: const TextStyle(
                  color: AppColors.seed, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.score, required this.lastCheck});

  final double? score;
  final DateTime? lastCheck;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (score == null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.insights_rounded,
                size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No readiness check yet. Tap "Check My Readiness" to get your first score.',
                style: TextStyle(color: onSurface.withOpacity(0.75)),
              ),
            ),
          ],
        ),
      );
    }

    final s = score!;
    return AppCard(
      child: Row(
        children: [
          ScoreRing(score: s, size: 112, strokeWidth: 10),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall readiness',
                    style: TextStyle(
                        fontSize: 13, color: onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(
                  ReadinessCalculator.categoryFor(s),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scoreColor(s),
                  ),
                ),
                if (lastCheck != null) ...[
                  const SizedBox(height: 6),
                  Text('Last check: ${DateHelper.format(lastCheck!)}',
                      style: TextStyle(
                          fontSize: 12, color: onSurface.withOpacity(0.6))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
