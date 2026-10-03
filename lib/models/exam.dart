import '../utils/date_helper.dart';

/// The upcoming exam the student is preparing for.
class Exam {
  final String name;
  final DateTime date;
  final int totalSubjects;

  const Exam({
    required this.name,
    required this.date,
    required this.totalSubjects,
  });

  /// Whole days between today and the exam date (negative if it has passed).
  int get daysLeft {
    final examDay = DateTime(date.year, date.month, date.day);
    return examDay.difference(DateHelper.today()).inDays;
  }

  String get daysLeftLabel {
    final d = daysLeft;
    if (d < 0) return 'Exam date has passed';
    if (d == 0) return 'Exam is today';
    if (d == 1) return '1 day left';
    return '$d days left';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date.toIso8601String(),
        'totalSubjects': totalSubjects,
      };

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      totalSubjects: (json['totalSubjects'] as num).toInt(),
    );
  }
}
