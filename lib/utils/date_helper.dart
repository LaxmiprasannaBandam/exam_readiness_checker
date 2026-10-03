/// Tiny date helpers so we don't need the `intl` package.
class DateHelper {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Oct 3, 2026"
  static String format(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// "Oct 3"
  static String short(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  /// Today's date with the time part removed.
  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
