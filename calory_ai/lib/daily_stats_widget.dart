import 'package:flutter/material.dart';
import 'data_entry.dart';
import 'package:intl/intl.dart';

class DailyStats extends StatelessWidget {
  final List<DataEntry> entries;
  final int calorieGoal;
  final int proteinGoal;

  const DailyStats(
      {required this.entries,
      required this.calorieGoal,
      required this.proteinGoal,
      super.key});

  @override
  Widget build(BuildContext context) {
    int totalCalories = 0;
    int totalProtein = 0;

    for (var entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
    }

    int remainingCalories = calorieGoal - totalCalories;
    int remainingProtein = proteinGoal - totalProtein;

    Locale locale = Localizations.localeOf(context);
    DateFormat dateFormat = DateFormat.MEd(locale.toString());
    final formattedDate = dateFormat.format(entries.first.date);

    final double calorieProgress =
        (calorieGoal > 0) ? totalCalories / calorieGoal : 0.0;
    final double proteinProgress =
        (proteinGoal > 0) ? totalProtein / proteinGoal : 0.0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stats for $formattedDate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 10),
                Text(
                  'Total Calories: $totalCalories / $calorieGoal',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 34),
                Text(
                  'Remaining: $remainingCalories',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: calorieProgress > 1 ? 1 : calorieProgress,
                backgroundColor: Colors.grey[300],
                color: calorieProgress > 1 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  'Total Protein: $totalProtein / $proteinGoal',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 34),
                Text(
                  'Remaining: $remainingProtein',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: proteinProgress > 1 ? 1 : proteinProgress,
                backgroundColor: Colors.grey[300],
                color: proteinProgress > 1 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
