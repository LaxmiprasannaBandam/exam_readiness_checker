import 'package:exam_readiness_checker/models/assessment.dart';
import 'package:exam_readiness_checker/models/subject.dart';
import 'package:exam_readiness_checker/services/readiness_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadinessCalculator', () {
    test('perfect answers give 100%', () {
      const input = AssessmentInput(
          syllabus: 100, questions: 300, mockScore: 100, revisions: 10, confidence: 5);
      expect(ReadinessCalculator.calculateScore(input), closeTo(100, 0.001));
    });

    test('practice questions are capped (900 questions is still 100%)', () {
      expect(ReadinessCalculator.practiceScore(900), 100);
      expect(ReadinessCalculator.practiceScore(150), 50);
    });

    test('weighted formula matches a hand calculation', () {
      // 0.30*65 + 0.25*58 + 0.20*100 + 0.15*40 + 0.10*60 = 66.0
      const input = AssessmentInput(
          syllabus: 65, questions: 320, mockScore: 58, revisions: 4, confidence: 3);
      expect(ReadinessCalculator.calculateScore(input), closeTo(66.0, 0.001));
    });

    test('categories use the right boundaries', () {
      expect(ReadinessCalculator.categoryFor(85), 'Highly Prepared');
      expect(ReadinessCalculator.categoryFor(80), 'Highly Prepared');
      expect(ReadinessCalculator.categoryFor(79), 'Moderately Prepared');
      expect(ReadinessCalculator.categoryFor(60), 'Moderately Prepared');
      expect(ReadinessCalculator.categoryFor(59), 'Needs More Preparation');
      expect(ReadinessCalculator.categoryFor(40), 'Needs More Preparation');
      expect(ReadinessCalculator.categoryFor(39), 'Early Preparation Stage');
      expect(ReadinessCalculator.categoryFor(0), 'Early Preparation Stage');
    });

    test('analyse always returns strengths, weaknesses and suggestions', () {
      final result = ReadinessCalculator.analyse(AssessmentInput.empty, const []);
      expect(result.strengths, isNotEmpty);
      expect(result.weaknesses, isNotEmpty);
      expect(result.suggestions, isNotEmpty);
    });
  });

  group('Subject', () {
    test('status depends on the preparation score', () {
      const strong = Subject(
          id: '1', name: 'A', completion: 100, questionsPracticed: 200, confidence: 5);
      const weak = Subject(
          id: '2', name: 'B', completion: 10, questionsPracticed: 0, confidence: 1);
      expect(strong.status, 'Strong');
      expect(weak.status, 'Just Started');
    });

    test('json round trip keeps the data', () {
      const s = Subject(
          id: 'x', name: 'Networks', completion: 55, questionsPracticed: 30, confidence: 2);
      final copy = Subject.fromJson(s.toJson());
      expect(copy.name, 'Networks');
      expect(copy.completion, 55);
      expect(copy.confidence, 2);
    });
  });
}
