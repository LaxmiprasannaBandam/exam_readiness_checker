import 'package:flutter/material.dart';

import '../models/readiness_result.dart';
import '../state/app_scope.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/score_ring.dart';

/// Shows the score, category, breakdown, strengths, weak areas, suggestions.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The result is passed as a route argument by the Assessment screen.
    // If it is missing, recalculate it from the saved answers.
    final args = ModalRoute.of(context)?.settings.arguments;
    final ReadinessResult result =
        args is ReadinessResult ? args : AppScope.of(context).latestResult;

    final color = scoreColor(result.score);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Results')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            // ---- Score header ----
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ScoreRing(score: result.score, size: 170, strokeWidth: 14),
                  const SizedBox(height: 18),
                  Text(
                    'Your Readiness Score: ${result.score.round()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.category,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    result.summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15, color: onSurface.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This preparation level is a simple app-generated estimate for study planning. '
                    'It is not a professional or scientific assessment and cannot predict your exam result.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11.5, color: onSurface.withOpacity(0.55)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Breakdown ----
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Score breakdown',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  for (final c in result.components) _ComponentRow(c: c),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _BulletCard(
              title: 'Strengths',
              icon: Icons.thumb_up_alt_rounded,
              color: AppColors.success,
              items: result.strengths,
            ),
            const SizedBox(height: 16),
            _BulletCard(
              title: 'Areas to improve',
              icon: Icons.flag_rounded,
              color: AppColors.warning,
              items: result.weaknesses,
            ),
            const SizedBox(height: 16),
            _BulletCard(
              title: 'Study suggestions',
              icon: Icons.lightbulb_rounded,
              color: AppColors.seed,
              items: result.suggestions,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                final state = AppScope.read(context);
                state.setTab(2); // Study Plan tab
                // Go back to the main screen (the route named '/home').
                Navigator.popUntil(
                    context, ModalRoute.withName(AppRoutes.shell));
              },
              icon: const Icon(Icons.event_note_rounded),
              label: const Text('View my study plan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
              icon: const Icon(Icons.show_chart_rounded),
              label: const Text('See progress history'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.c});

  final ComponentScore c;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = scoreColor(c.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(c.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text('${c.value.round()}%',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (c.value / 100).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text('Counts for ${(c.weight * 100).round()}% of the score',
              style:
                  TextStyle(fontSize: 11, color: onSurface.withOpacity(0.55))),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 7, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
