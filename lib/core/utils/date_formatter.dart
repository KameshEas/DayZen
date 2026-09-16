/// Utility for consistent date/time formatting across the app.
library;

import '../config/app_config.dart';

class DateFormatter {
  DateFormatter._();

  static String weekdayAbbr(DateTime date) {
    return AppConfig.weekdayLabels[date.weekday - 1];
  }

  static String weekdayFull(DateTime date) {
    return AppConfig.weekdayFull[date.weekday - 1];
  }

  static String monthAbbr(int month) {
    return AppConfig.monthAbbreviations[month - 1];
  }

  static String monthFull(int month) {
    return AppConfig.monthFull[month - 1];
  }

  static String formatDate(DateTime date) {
    return '${weekdayAbbr(date)}, ${monthAbbr(date.month)} ${date.day}';
  }

  static String formatDateFull(DateTime date) {
    return '${weekdayFull(date)}, ${monthFull(date.month)} ${date.day}';
  }

  static String formatMonthYear(DateTime date) {
    return '${monthFull(date.month).toUpperCase()} ${date.year}';
  }

  static String formatTime(int hour, int minute) {
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatTimeRange(int startHour, int startMinute, int endHour, int endMinute) {
    return '${formatTime(startHour, startMinute)} – ${formatTime(endHour, endMinute)}';
  }

  static String formatTaskSchedule(DateTime date, int hour, int minute) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    final diff = selected.difference(today).inDays;
    final dayLabel = diff == 0
        ? 'Today'
        : diff == 1
            ? 'Tomorrow'
            : '${weekdayFull(date)}, ${date.day} ${monthAbbr(date.month)}';

    final time = formatTime(hour, minute);
    return '$dayLabel at $time';
  }
}
