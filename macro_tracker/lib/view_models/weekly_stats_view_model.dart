import 'package:macro_tracker/models/weekly_stat.dart';
import '../models/data_entry.dart';

class WeeklyStatsViewModel {
  List<WeeklyStat> getWeeklyStats(List<DataEntry> entries) {
    List<WeeklyStat> weeklyStats = [];
    if (entries.isEmpty) return [];

    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    DateTime startOfWeek = _getStartOfWeek(sortedEntries.first.date);
    DateTime endOfWeek = _getEndOfWeek(sortedEntries.first.date);

    List<DataEntry> entriesForWeek = [];
    for (var entry in sortedEntries) {
      if (entry.date.isAfter(endOfWeek)) {
        weeklyStats.add(
            _getWeeklyStatFromEntries(startOfWeek, endOfWeek, entriesForWeek));
        entriesForWeek = [];
        startOfWeek = _getStartOfWeek(entry.date);
        endOfWeek = _getEndOfWeek(entry.date);
      }
      entriesForWeek.add(entry);
    }

    weeklyStats
        .add(_getWeeklyStatFromEntries(startOfWeek, endOfWeek, entriesForWeek));

    return weeklyStats;
  }

  WeeklyStat _getWeeklyStatFromEntries(
      DateTime weekStartDate, DateTime weekEndDate, List<DataEntry> entries) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarb = 0;
    List<int> numberOfWeekDaysWithData = [];

    for (var entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalFat += entry.fat;
      totalCarb += entry.carb;
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
            (totalProtein / numberOfWeekDaysWithData.length).round(),
        averageFat: (totalFat / numberOfWeekDaysWithData.length).round(),
        averageCarb: (totalCarb / numberOfWeekDaysWithData.length).round());
  }

  DateTime _getStartOfWeek(DateTime date) {
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getEndOfWeek(DateTime date) {
    while (date.weekday != DateTime.sunday) {
      date = date.add(const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
