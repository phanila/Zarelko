extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
extension DateExtension on DateTime {
  DateTime zeroTime() {
    return copyWith(hour: 0,minute: 0,second: 0, millisecond: 0,microsecond: 0);
  }
}