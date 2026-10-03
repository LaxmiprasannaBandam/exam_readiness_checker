import 'package:exam_readiness_checker/main.dart';
import 'package:exam_readiness_checker/services/storage_service.dart';
import 'package:exam_readiness_checker/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows splash, then the dashboard with demo data',
      (WidgetTester tester) async {
    // Pretend the device has no saved data (first run).
    SharedPreferences.setMockInitialValues({});
    final state = AppState(StorageService());
    await tester.runAsync(() => state.load());

    await tester.pumpWidget(ExamReadinessApp(appState: state));
    expect(find.text('Exam Readiness Checker'), findsOneWidget);

    // Wait for the splash timer, then let the page transition finish.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Ready to check your preparation?'), findsOneWidget);
    expect(find.text('Semester End Examination'), findsOneWidget);
  });
}
