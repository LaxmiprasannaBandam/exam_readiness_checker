import 'package:flutter/material.dart';

import '../services/study_plan_generator.dart';
import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

/// "Study Plan" tab: a plan built locally from the weak areas.
class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  // Tasks the user has ticked (kept only while the app is open).
  final Set<String> _done = {};

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final plan = StudyPlanGenerator.generate(
      subjects: state.subjects,
      input: state.input,
      exam: state.exam,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Study Plan')),
      body: plan.isEmpty
          ? EmptyState(
              icon: Icons.event_note_rounded,
              title: 'No plan yet',
              message: 'Add your subjects and we will build a simple plan '
                  'based on your weak areas.',
              actionLabel: 'Set up my exam',
              onAction: () => Navigator.pushNamed(context, AppRoutes.setup),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (state.exam != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded,
                            size: 18, color: AppColors.seed),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${state.exam!.name}  •  ${state.exam!.daysLeftLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final day in plan)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 4),
                          child: Text(day.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                        for (final task in day.tasks)
                          CheckboxListTile(
                            value: _done.contains('${day.title}|${task.text}'),
                            onChanged: (checked) {
                              setState(() {
                                final key = '${day.title}|${task.text}';
                                if (checked == true) {
                                  _done.add(key);
                                } else {
                                  _done.remove(key);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            title: Text(
                              task.text,
                              style: TextStyle(
                                decoration:
                                    _done.contains('${day.title}|${task.text}')
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                color:
                                    _done.contains('${day.title}|${task.text}')
                                        ? onSurface.withOpacity(0.45)
                                        : onSurface,
                              ),
                            ),
                            secondary: Icon(task.icon,
                                color: AppColors.seed.withOpacity(0.8)),
                          ),
                      ],
                    ),
                  ),
                Text(
                  'This plan is generated on your device from simple rules. '
                  'Adjust it to fit your own schedule.',
                  style: TextStyle(
                      fontSize: 12, color: onSurface.withOpacity(0.55)),
                ),
              ],
            ),
    );
  }
}
