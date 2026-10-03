import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/confirm_dialog.dart';

/// "Profile" tab: theme switch, edit exam, reset/clear data, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // ---- Profile card ----
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.primary.withOpacity(0.14),
                  child: Icon(Icons.person_rounded,
                      size: 34, color: scheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        'Your data stays on this device.',
                        style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.65)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Preferences ----
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  value: state.darkMode,
                  onChanged: (v) => state.setDarkMode(v),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark theme'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_calendar_rounded),
                  title: const Text('Edit exam & subjects'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.setup),
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('Progress history'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Data ----
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.science_rounded),
                  title: const Text('Reload demo data'),
                  subtitle: const Text('Replaces your data with the sample'),
                  onTap: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'Reload demo data?',
                      message:
                          'This replaces your current exam, subjects and history with the sample data.',
                      confirmLabel: 'Reload',
                    );
                    if (ok) state.resetToSample();
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                  title: const Text('Clear all data',
                      style: TextStyle(color: AppColors.danger)),
                  subtitle: const Text('Start completely fresh'),
                  onTap: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'Clear all data?',
                      message:
                          'This permanently deletes your exam, subjects and history from this device.',
                      confirmLabel: 'Clear',
                    );
                    if (ok) state.clearAllData();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- About ----
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Exam Readiness Checker v1.0.0\n\n'
                  'This is an educational productivity tool. The readiness score and '
                  'preparation levels come from a simple formula and are not a medical, '
                  'psychological, professional or scientific assessment.',
                  style: TextStyle(
                      height: 1.4, color: scheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
