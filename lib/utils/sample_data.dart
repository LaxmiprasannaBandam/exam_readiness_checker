import '../models/assessment.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../services/readiness_calculator.dart';

/// Demo data used on the very first run so the app looks populated.
class SampleData {
  static Exam exam() {
    final now = DateTime.now();
    return Exam(
      name: 'Semester End Examination',
      date: DateTime(now.year, now.month, now.day).add(const Duration(days: 21)),
      totalSubjects: 4,
    );
  }

  static List<Subject> subjects() => const [
        Subject(id: 's1', name: 'Data Structures', completion: 80, questionsPracticed: 120, confidence: 4),
        Subject(id: 's2', name: 'Computer Networks', completion: 65, questionsPracticed: 70, confidence: 3),
        Subject(id: 's3', name: 'Operating Systems', completion: 45, questionsPracticed: 40, confidence: 2),
        Subject(id: 's4', name: 'Database Management Systems', completion: 70, questionsPracticed: 90, confidence: 4),
      ];

  /// The most recent assessment answers.
  static const AssessmentInput latestInput = AssessmentInput(
    syllabus: 65,
    questions: 320,
    mockScore: 58,
    revisions: 4,
    confidence: 3,
  );

  /// Three earlier checks so the history chart has something to show.
  static List<AssessmentRecord> history() {
    final now = DateTime.now();
    const early = AssessmentInput(
        syllabus: 40, questions: 150, mockScore: 45, revisions: 2, confidence: 2);
    const middle = AssessmentInput(
        syllabus: 52, questions: 230, mockScore: 52, revisions: 3, confidence: 3);

    AssessmentRecord make(int daysAgo, AssessmentInput input) {
      return AssessmentRecord(
        date: now.subtract(Duration(days: daysAgo)),
        score: ReadinessCalculator.calculateScore(input),
        input: input,
      );
    }

    return [make(14, early), make(7, middle), make(2, latestInput)];
  }
}
