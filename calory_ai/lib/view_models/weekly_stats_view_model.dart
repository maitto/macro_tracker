import '../models/data_entry.dart';

class WeeklyStatsViewModel {
  List<Map<String, dynamic>> getWeeklyStats(List<DataEntry> entries) {
    List<Map<String, dynamic>> weeklyStats = [];
    if (entries.isEmpty) return weeklyStats;

    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    DateTime weekStartDate = _findPreviousMonday(sortedEntries.first.date);
    DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));
    int totalCalories = 0;
    int totalProtein = 0;
    List<int> weekDays = [];

    for (var entry in sortedEntries) {
      if (entry.date.isAfter(weekEndDate)) {
        if (weekDays.isNotEmpty) {
          weeklyStats.add({
            'startDate': weekStartDate,
            'endDate': weekEndDate,
            'numberOfWeekDays': weekDays.length,
            'averageCalories': (totalCalories / weekDays.length).round(),
            'averageProtein': (totalProtein / weekDays.length).round(),
          });
        }

        weekStartDate = weekEndDate.add(const Duration(days: 1));
        weekEndDate = weekStartDate.add(const Duration(days: 6));
        totalCalories = 0;
        totalProtein = 0;
        weekDays = [];
      }

      totalCalories += entry.calories;
      totalProtein += entry.protein;
      if (!(weekDays.contains(entry.date.weekday))) {
        weekDays.add(entry.date.weekday);
      }
    }

    if (weekDays.isNotEmpty) {
      weeklyStats.add({
        'startDate': weekStartDate,
        'endDate': weekEndDate,
        'numberOfWeekDays': weekDays.length,
        'averageCalories': (totalCalories / weekDays.length).round(),
        'averageProtein': (totalProtein / weekDays.length).round(),
      });
    }

    return weeklyStats;
  }

  DateTime _findPreviousMonday(DateTime date) {
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }
}