import 'package:calory_ai/models/weekly_stat.dart';

import '../models/data_entry.dart';

class WeeklyStatsViewModel {
  List<WeeklyStat> getWeeklyStats(List<DataEntry> entries) {
    List<WeeklyStat> weeklyStats = [];
    if (entries.isEmpty) return [];

    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    DateTime weekStartDate = _findPreviousMonday(sortedEntries.first.date);
    DateTime weekEndDate = weekStartDate.add(const Duration(days: 6));

    List<DataEntry> entriesForWeek = [];
    for (var entry in sortedEntries) {
      if (entry.date.isAfter(weekEndDate)) {
        weeklyStats.add(_getWeeklyStatFromEntries(
            weekStartDate, weekEndDate, entriesForWeek));
        entriesForWeek = [];
        weekStartDate = weekEndDate.add(const Duration(days: 1));
        weekEndDate = weekStartDate.add(const Duration(days: 6));
      }
      entriesForWeek.add(entry);
    }

    return weeklyStats;
  }

  WeeklyStat _getWeeklyStatFromEntries(
      DateTime weekStartDate, DateTime weekEndDate, List<DataEntry> entries) {
    int totalCalories = 0;
    int totalProtein = 0;
    List<int> numberOfWeekDaysWithData = [];

    for (var entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      if (!(numberOfWeekDaysWithData.contains(entry.date.weekday))) {
        numberOfWeekDaysWithData.add(entry.date.weekday);
      }
    }

    return WeeklyStat(
        startDate: weekStartDate,
        endDate: weekEndDate,
        numberOfWeekDaysWithData: numberOfWeekDaysWithData.length,
        averageCalories:
            (totalCalories / numberOfWeekDaysWithData.length).round(),
        averageProtein:
            (totalProtein / numberOfWeekDaysWithData.length).round());
  }

  DateTime _findPreviousMonday(DateTime date) {
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }
}
