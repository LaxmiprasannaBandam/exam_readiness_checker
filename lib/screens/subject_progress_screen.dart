import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_form_sheet.dart';

/// "Progress" tab: one card per subject, with update and delete.
class SubjectProgressScreen extends StatelessWidget {
  const SubjectProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Progress'),
        actions: [
          IconButton(
            tooltip: 'Progress history',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final subject = await showSubjectForm(context);
          if (subject != null) state.addSubject(subject);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add subject'),
      ),
      body: state.subjects.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'No subjects yet',
              message:
                  'Add the subjects you are studying to track your progress.',
              actionLabel: 'Set up my exam',
              onAction: () => Navigator.pushNamed(context, AppRoutes.setup),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              children: [
                // ---- Overall summary ----
                AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.seed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.insights_rounded,
                            color: AppColors.seed),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${state.subjects.length} subjects  •  '
                              '${state.averageCompletion.round()}% average completion',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.totalSubjectQuestions} practice questions in total',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                for (final subject in state.subjects)
                  SubjectCard(
                    subject: subject,
                    onEdit: () async {
                      final updated =
                          await showSubjectForm(context, existing: subject);
                      if (updated != null) state.updateSubject(updated);
                    },
                    onDelete: () async {
                      final ok = await confirmDialog(
                        context,
                        title: 'Delete subject?',
                        message: 'Remove "${subject.name}" from your list?',
                        confirmLabel: 'Delete',
                      );
                      if (ok) state.removeSubject(subject.id);
                    },
                  ),
              ],
            ),
    );
  }
}
