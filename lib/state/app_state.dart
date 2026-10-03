import 'package:flutter/foundation.dart';

import '../models/assessment.dart';
import '../models/exam.dart';
import '../models/readiness_result.dart';
import '../models/subject.dart';
import '../services/readiness_calculator.dart';
import '../services/storage_service.dart';
import '../utils/sample_data.dart';

/// The single place that holds the app's data.
///
/// It extends [ChangeNotifier]: whenever we call `notifyListeners()`, every
/// screen that "listens" (through AppScope.of(context)) rebuilds itself.
/// This is Flutter's built-in state management - no extra package needed.
class AppState extends ChangeNotifier {
  AppState(this._storage);

  final StorageService _storage;

  Exam? exam;
  List<Subject> subjects = [];
  AssessmentInput input = AssessmentInput.empty;
  List<AssessmentRecord> history = [];

  /// True while the user is still looking at the built-in demo data.
  bool isSampleData = false;
  bool darkMode = false;

  /// Which bottom-navigation tab is selected (0 = Home).
  int selectedTab = 0;

  // ------------------------------------------------------------------
  // Loading
  // ------------------------------------------------------------------

  /// Called once in main() before the app starts.
  Future<void> load() async {
    darkMode = await _storage.loadDarkMode();
    final data = await _storage.loadData();

    if (data == null) {
      // First run (or damaged data): start with demo data.
      _applySample();
      await _persist();
      return;
    }

    try {
      final examJson = data['exam'];
      exam = examJson == null
          ? null
          : Exam.fromJson(examJson as Map<String, dynamic>);
      subjects = (data['subjects'] as List)
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList();
      input = AssessmentInput.fromJson(data['input'] as Map<String, dynamic>);
      history = (data['history'] as List)
          .map((e) => AssessmentRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      isSampleData = data['isSampleData'] as bool? ?? false;
    } catch (_) {
      _applySample();
      await _persist();
    }
  }

  void _applySample() {
    exam = SampleData.exam();
    subjects = SampleData.subjects();
    input = SampleData.latestInput;
    history = SampleData.history();
    isSampleData = true;
  }

  // ------------------------------------------------------------------
  // Saving
  // ------------------------------------------------------------------

  Map<String, dynamic> _toJson() => {
        'exam': exam?.toJson(),
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'input': input.toJson(),
        'history': history.map((h) => h.toJson()).toList(),
        'isSampleData': isSampleData,
      };

  Future<void> _persist() => _storage.saveData(_toJson());

  /// Notify the UI first (instant), then save to the device.
  void _changed() {
    notifyListeners();
    _persist();
  }

  // ------------------------------------------------------------------
  // Read helpers
  // ------------------------------------------------------------------

  /// Latest saved readiness score, or null if there is no history yet.
  double? get latestScore => history.isEmpty ? null : history.last.score;

  DateTime? get latestCheckDate => history.isEmpty ? null : history.last.date;

  /// Average syllabus completion of all subjects (0 if none).
  double get averageCompletion {
    if (subjects.isEmpty) return 0;
    final total = subjects.fold<double>(0, (sum, s) => sum + s.completion);
    return total / subjects.length;
  }

  int get totalSubjectQuestions =>
      subjects.fold<int>(0, (sum, s) => sum + s.questionsPracticed);

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------

  void setTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await _storage.saveDarkMode(value);
  }

  /// Saves the exam + subject list from the Exam Setup screen.
  void saveExamSetup(Exam newExam, List<Subject> newSubjects) {
    exam = newExam;
    subjects = List.of(newSubjects);
    isSampleData = false;
    _changed();
  }

  void addSubject(Subject subject) {
    subjects = [...subjects, subject];
    isSampleData = false;
    _changed();
  }

  void updateSubject(Subject updated) {
    subjects = [for (final s in subjects) s.id == updated.id ? updated : s];
    isSampleData = false;
    _changed();
  }

  void removeSubject(String id) {
    subjects = subjects.where((s) => s.id != id).toList();
    isSampleData = false;
    _changed();
  }

  /// Runs the calculator, stores the answers + a history record,
  /// and returns the full result for the Results screen.
  ReadinessResult submitAssessment(AssessmentInput newInput) {
    input = newInput;
    final result = ReadinessCalculator.analyse(newInput, subjects);

    history = [
      ...history,
      AssessmentRecord(date: DateTime.now(), score: result.score, input: newInput),
    ];
    // Keep only the latest 30 checks so storage stays small.
    if (history.length > 30) {
      history = history.sublist(history.length - 30);
    }
    isSampleData = false;
    _changed();
    return result;
  }

  /// The result for the most recent answers (used if Results has no arguments).
  ReadinessResult get latestResult =>
      ReadinessCalculator.analyse(input, subjects);

  void resetToSample() {
    _applySample();
    selectedTab = 0;
    _changed();
  }

  void clearAllData() {
    exam = null;
    subjects = [];
    input = AssessmentInput.empty;
    history = [];
    isSampleData = false;
    selectedTab = 0;
    _changed();
  }
}
