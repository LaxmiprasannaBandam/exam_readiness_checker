/// One subject the student is preparing for.
class Subject {
  final String id;
  final String name;

  /// Syllabus completion, 0-100.
  final double completion;

  /// Number of practice questions solved for this subject.
  final int questionsPracticed;

  /// Self-rated confidence, 1-5.
  final int confidence;

  const Subject({
    required this.id,
    required this.name,
    required this.completion,
    required this.questionsPracticed,
    required this.confidence,
  });

  Subject copyWith({
    String? name,
    double? completion,
    int? questionsPracticed,
    int? confidence,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      completion: completion ?? this.completion,
      questionsPracticed: questionsPracticed ?? this.questionsPracticed,
      confidence: confidence ?? this.confidence,
    );
  }

  /// A simple 0-100 preparation score for ONE subject.
  /// 50% syllabus completion + 30% practice (100 questions = full marks)
  /// + 20% confidence.
  double get preparationScore {
    final practice =
        (questionsPracticed / 100.0).clamp(0.0, 1.0).toDouble() * 100.0;
    final conf = confidence / 5.0 * 100.0;
    return completion * 0.5 + practice * 0.3 + conf * 0.2;
  }

  /// Friendly status label shown on the subject card.
  String get status {
    final s = preparationScore;
    if (s >= 80) return 'Strong';
    if (s >= 60) return 'On Track';
    if (s >= 40) return 'Needs Work';
    return 'Just Started';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'completion': completion,
        'questionsPracticed': questionsPracticed,
        'confidence': confidence,
      };

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      completion: (json['completion'] as num).toDouble(),
      questionsPracticed: (json['questionsPracticed'] as num).toInt(),
      confidence: (json['confidence'] as num).toInt(),
    );
  }
}
