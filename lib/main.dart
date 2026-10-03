import 'package:flutter/material.dart';

import 'screens/assessment_screen.dart';
import 'screens/exam_setup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/main_shell.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Needed because we use plugins (shared_preferences) before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Create the app state and load saved data from the device.
  final appState = AppState(StorageService());
  await appState.load();

  runApp(ExamReadinessApp(appState: appState));
}

class ExamReadinessApp extends StatelessWidget {
  const ExamReadinessApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // AppScope shares the AppState with every screen below it.
    return AppScope(
      state: appState,
      // Builder gives us a context *below* AppScope, so we can listen to it.
      child: Builder(
        builder: (context) {
          final state = AppScope.of(context);
          return MaterialApp(
            title: 'Exam Readiness Checker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.darkMode ? ThemeMode.dark : ThemeMode.light,
            // Named routes: the app starts at '/' (the splash screen).
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.shell: (_) => const MainShell(),
              AppRoutes.setup: (_) => const ExamSetupScreen(),
              AppRoutes.assessment: (_) => const AssessmentScreen(),
              AppRoutes.results: (_) => const ResultsScreen(),
              AppRoutes.history: (_) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
