/// Form validators. Each returns `null` when the value is OK,
/// or a friendly error message when it is not.
class Validators {
  static String? requiredText(String? value, String fieldName,
      {int maxLength = 60}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    if (value.trim().length > maxLength) {
      return '$fieldName is too long (max $maxLength characters)';
    }
    return null;
  }

  /// A number from 0 to 100 (decimals allowed).
  static String? percentage(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = double.tryParse(value.trim());
    if (number == null) return 'Enter a valid number';
    if (number < 0 || number > 100) {
      return '$fieldName must be between 0 and 100';
    }
    return null;
  }

  /// A whole number from [min] to [max].
  static String? wholeNumber(String? value, String fieldName,
      {int min = 0, int max = 100000}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final number = int.tryParse(value.trim());
    if (number == null) return 'Enter a whole number';
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Confidence must be 1-5.
  static String? confidence(int? value) {
    if (value == null || value < 1 || value > 5) {
      return 'Confidence must be between 1 and 5';
    }
    return null;
  }

  /// Exam date must be chosen and must not be in the past.
  static String? examDate(DateTime? date) {
    if (date == null) return 'Please choose the exam date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isBefore(today)) return 'Exam date cannot be in the past';
    return null;
  }
}
