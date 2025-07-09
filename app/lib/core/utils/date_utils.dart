
extension DateUtils on DateTime {

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isOverdue(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    return isAfter(today);
  }

  bool get isNextWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfNextWeek = today.add(const Duration(days: 8));

    return (isAtSameMomentAs(tomorrow) || isAfter(tomorrow)) && isBefore(endOfNextWeek);
  }

  bool get isNextMonth {
    final now = DateTime.now();

    final isSameYearNextMonth = year == now.year && month == now.month + 1;
    final isNextYearJanuary = year == now.year + 1 && now.month == 12 && month == 1;

    return isSameYearNextMonth || isNextYearJanuary;
  }
}
