import 'package:calory_ai/models/meal_type.dart';
import 'package:test/test.dart';
import 'package:calory_ai/models/weekly_stat.dart';
import 'package:calory_ai/view_models/weekly_stats_view_model.dart';
import 'package:calory_ai/models/data_entry.dart';

void main() {
  group('WeeklyStatsViewModel', () {
    final viewModel = WeeklyStatsViewModel();

    test('getWeeklyStats returns empty list for no entries', () {
      List<DataEntry> entries = [];
      List<WeeklyStat> result = viewModel.getWeeklyStats(entries);
      expect(result, isEmpty);
    });

    test('getWeeklyStats calculates correct stats for one week of entries', () {
      List<DataEntry> entries = [
        DataEntry(
            date: DateTime(2023, 7, 3),
            calories: 2000,
            protein: 100,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 4),
            calories: 2500,
            protein: 120,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 5),
            calories: 1800,
            protein: 90,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 6),
            calories: 2200,
            protein: 110,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 7),
            calories: 2100,
            protein: 105,
            type: MealType.types.first),
      ];
      List<WeeklyStat> result = viewModel.getWeeklyStats(entries);
      expect(result.length, 1);
      expect(result[0].startDate, DateTime(2023, 7, 3));
      expect(result[0].endDate, DateTime(2023, 7, 9, 23, 59, 59, 999));
      expect(result[0].numberOfWeekDaysWithData, 5);
      expect(
          result[0].averageCalories, (2000 + 2500 + 1800 + 2200 + 2100) ~/ 5);
      expect(result[0].averageProtein, (100 + 120 + 90 + 110 + 105) ~/ 5);
    });

    test('getWeeklyStats splits entries correctly across weeks', () {
      List<DataEntry> entries = [
        DataEntry(
            date: DateTime(2023, 7, 3),
            calories: 2000,
            protein: 100,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 4),
            calories: 2500,
            protein: 120,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 5),
            calories: 1800,
            protein: 90,
            type: MealType.types.first),
        DataEntry(
            date: DateTime(2023, 7, 11),
            calories: 2200,
            protein: 110,
            type: MealType.types.first),
      ];
      List<WeeklyStat> result = viewModel.getWeeklyStats(entries);
      expect(result.length, 2);

      // First week stats
      expect(result[0].startDate, DateTime(2023, 7, 3));
      expect(result[0].endDate, DateTime(2023, 7, 9, 23, 59, 59, 999));
      expect(result[0].numberOfWeekDaysWithData, 3);
      expect(result[0].averageCalories, (2000 + 2500 + 1800) ~/ 3);
      expect(result[0].averageProtein, (100 + 120 + 90) ~/ 3);

      // Second week stats
      expect(result[1].startDate, DateTime(2023, 7, 10));
      expect(result[1].endDate, DateTime(2023, 7, 16, 23, 59, 59, 999));
      expect(result[1].numberOfWeekDaysWithData, 1);
      expect(result[1].averageCalories, 2200);
      expect(result[1].averageProtein, 110);
    });
  });
}
