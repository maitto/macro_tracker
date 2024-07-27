import 'package:calory_ai/view_models/weekly_stats_view_model.dart';
import 'package:flutter/material.dart';
import '../models/data_entry.dart';
import 'package:intl/intl.dart';
import '../utils/size_contants.dart';

class WeeklyStatsPage extends StatelessWidget {
  final List<DataEntry> entries;
  const WeeklyStatsPage({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyStats = WeeklyStatsViewModel().getWeeklyStats(entries);

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
                    '${DateFormat.yMMMd().format(weekStats.startDate)} - ${DateFormat.yMMMd().format(weekStats.endDate)}',
                    style: TextStyle(
                      fontSize: AppFont.xLarge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizedBox.medium),
                  Row(
                    children: [
                      Text(
                        'Number of days with data: ${weekStats.numberOfWeekDaysWithData}',
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
                        'Average Daily Calories: ${weekStats.averageCalories}',
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
                        'Average Daily Protein: ${weekStats.averageProtein}',
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
}
