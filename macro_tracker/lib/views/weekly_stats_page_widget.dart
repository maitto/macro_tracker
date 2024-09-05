import 'package:macro_tracker/view_models/weekly_stats_view_model.dart';
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

    if (entries.isNotEmpty) {
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBoxWithHeight.medium,
                    Row(
                      children: [
                        Text(
                          'Number of days with data: ${weekStats.numberOfWeekDaysWithData}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    SizedBoxWithHeight.medium,
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orange),
                        SizedBoxWithWidth.medium,
                        Text(
                          'Average Daily Calories: ${weekStats.averageCalories}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBoxWithHeight.medium,
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.blue),
                        SizedBoxWithWidth.medium,
                        Text(
                          'Average Daily Protein: ${weekStats.averageProtein}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBoxWithHeight.medium,
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.red),
                        SizedBoxWithWidth.medium,
                        Text(
                          'Average Daily Fat: ${weekStats.averageFat}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBoxWithHeight.medium,
                    Row(
                      children: [
                        const Icon(Icons.grass, color: Colors.yellow),
                        SizedBoxWithWidth.medium,
                        Text(
                          'Average Daily Carb: ${weekStats.averageCarb}',
                          style: Theme.of(context).textTheme.titleMedium,
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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Stats'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Center(
                child: Text(
                  'Nothing here yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
