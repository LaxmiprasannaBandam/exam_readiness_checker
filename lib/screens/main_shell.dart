import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'study_plan_screen.dart';
import 'subject_progress_screen.dart';

/// The main container: 4 tabs + a bottom NavigationBar.
///
/// The selected tab lives in AppState (selectedTab) so any screen can switch
/// tabs by calling `AppScope.read(context).setTab(index)`.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      // IndexedStack keeps every tab alive, so scroll positions are kept.
      body: IndexedStack(
        index: state.selectedTab,
        children: const [
          HomeScreen(),
          SubjectProgressScreen(),
          StudyPlanScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.selectedTab,
        onDestinationSelected: state.setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Study Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
