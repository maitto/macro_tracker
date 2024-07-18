import 'package:flutter/material.dart';
import '../models/data_entry.dart';
import 'package:intl/intl.dart';
import '../size_contants.dart';

class WeeklyStatsPage extends StatelessWidget {
  final List<DataEntry> entries;
  const WeeklyStatsPage({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyStats = _calculateWeeklyStats(entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Stats'),
      ),
      body: ListView.builder(
        itemCount: weeklyStats.length,
        itemBuilder: (context, index) {
          final weekStats = weeklyStats[index];

          return Card(
            margin: const EdgeInsets.all(AppSpacing.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat.yMMMd().format(weekStats['startDate'])} - ${DateFormat.yMMMd().format(weekStats['endDate'])}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizedBox.medium),
                  Row(
                    children: [
                      Text(
                        'Number of days with data: ${weekStats['numberOfWeekDays']}',
                        style: const TextStyle(fontSize: AppFont.small),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizedBox.medium),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      const SizedBox(width: AppSizedBox.medium),
                      Text(
                        'Average Daily Calories: ${weekStats['averageCalories']}',
                        style: const TextStyle(fontSize: AppFont.large),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizedBox.medium),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Colors.blue),
                      const SizedBox(width: AppSizedBox.medium),
                      Text(
                        'Average Daily Protein: ${weekStats['averageProtein']}',
                        style: const TextStyle(fontSize: AppFont.large),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _calculateWeeklyStats(List<DataEntry> entries) {
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
