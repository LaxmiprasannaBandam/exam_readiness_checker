import 'package:flutter/material.dart';

import '../services/readiness_calculator.dart';
import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_chart.dart';

/// Shows every saved readiness check, with a line chart.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final records = state.history;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress History')),
      body: records.isEmpty
          ? EmptyState(
              icon: Icons.show_chart_rounded,
              title: 'No checks yet',
              message:
                  'Your readiness checks will appear here so you can see your progress over time.',
              actionLabel: 'Check my readiness',
              onAction: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.assessment),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                // ---- Chart card ----
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Readiness over time',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(_changeText(records.first.score, records.last.score,
                              records.length),
                          style: TextStyle(
                              fontSize: 13, color: onSurface.withOpacity(0.65))),
                      const SizedBox(height: 16),
                      HistoryChart(records: records),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text('All checks',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                // Newest first.
                for (final r in records.reversed)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: scoreColor(r.score).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${r.score.round()}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: scoreColor(r.score)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateHelper.format(r.date),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(ReadinessCalculator.categoryFor(r.score),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: onSurface.withOpacity(0.7))),
                              const SizedBox(height: 2),
                              Text(
                                'Syllabus ${r.input.syllabus.round()}%  •  Mock ${r.input.mockScore.round()}%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: onSurface.withOpacity(0.55)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  static String _changeText(double first, double last, int count) {
    if (count < 2) return 'Do another check later to see your trend.';
    final diff = (last - first).round();
    if (diff > 0) return '+$diff points since your first check';
    if (diff < 0) return '$diff points since your first check';
    return 'No change since your first check';
  }
}
