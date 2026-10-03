/// The numbers a student enters on the Readiness Assessment screen.
class AssessmentInput {
  final double syllabus; // 0-100
  final int questions; // practice questions solved
  final double mockScore; // 0-100
  final int revisions; // revision sessions completed
  final int confidence; // 1-5

  const AssessmentInput({
    required this.syllabus,
    required this.questions,
    required this.mockScore,
    required this.revisions,
    required this.confidence,
  });

  static const AssessmentInput empty = AssessmentInput(
    syllabus: 0,
    questions: 0,
    mockScore: 0,
    revisions: 0,
    confidence: 3,
  );

  Map<String, dynamic> toJson() => {
        'syllabus': syllabus,
        'questions': questions,
        'mockScore': mockScore,
        'revisions': revisions,
        'confidence': confidence,
      };

  factory AssessmentInput.fromJson(Map<String, dynamic> json) {
    return AssessmentInput(
      syllabus: (json['syllabus'] as num).toDouble(),
      questions: (json['questions'] as num).toInt(),
      mockScore: (json['mockScore'] as num).toDouble(),
      revisions: (json['revisions'] as num).toInt(),
      confidence: (json['confidence'] as num).toInt(),
    );
  }
}

/// One saved readiness check (shown in Progress History).
class AssessmentRecord {
  final DateTime date;
  final double score; // 0-100
  final AssessmentInput input;

  const AssessmentRecord({
    required this.date,
    required this.score,
    required this.input,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'input': input.toJson(),
      };

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) {
    return AssessmentRecord(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      input: AssessmentInput.fromJson(json['input'] as Map<String, dynamic>),
    );
  }
}
