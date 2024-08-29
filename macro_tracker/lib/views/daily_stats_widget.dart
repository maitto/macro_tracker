import '../models/goals.dart';
import '../utils/size_contants.dart';
import 'package:flutter/material.dart';
import '../models/data_entry.dart';
import 'package:intl/intl.dart';

class DailyStats extends StatelessWidget {
  final List<DataEntry> entries;
  final Goals goals;

  const DailyStats({super.key, required this.entries, required this.goals});

  @override
  Widget build(BuildContext context) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalFat = 0;
    int totalCarb = 0;

    for (var entry in entries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalFat += entry.fat;
      totalCarb = entry.carb;
    }

    int remainingCalories = goals.calorie - totalCalories;
    int remainingProtein = goals.protein - totalProtein;
    int remainingFat = goals.fat - totalFat;
    int remainingCarb = goals.carb - totalCarb;

    final double calorieProgress =
        (goals.calorie > 0) ? totalCalories / goals.calorie : 0.0;
    final double proteinProgress =
        (goals.protein > 0) ? totalProtein / goals.protein : 0.0;

    Locale locale = Localizations.localeOf(context);
    DateFormat dateFormat = DateFormat.MEd(locale.toString());
    final formattedDate = dateFormat.format(entries.first.date);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stats for $formattedDate',
              style: TextStyle(
                fontSize: AppFont.xLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSizedBox.medium),
            // calories section
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: AppSizedBox.medium),
                Text(
                  'Days Calories: $totalCalories / ${goals.calorie}',
                  style: const TextStyle(fontSize: AppFont.large),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: AppSizedBox.xxLarge),
                Text(
                  'Remaining: $remainingCalories',
                  style: const TextStyle(fontSize: AppFont.medium),
                ),
              ],
            ),
            const SizedBox(height: AppSizedBox.small),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: calorieProgress > 1 ? 1 : calorieProgress,
                backgroundColor: Colors.grey[300],
                color: calorieProgress > 1 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: AppSizedBox.large),
            // protein section
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.blue),
                const SizedBox(width: AppSizedBox.medium),
                Text(
                  'Days Protein: $totalProtein / ${goals.protein}',
                  style: const TextStyle(fontSize: AppFont.large),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: AppSizedBox.xxLarge),
                Text(
                  'Remaining: $remainingProtein',
                  style: const TextStyle(fontSize: AppFont.medium),
                ),
              ],
            ),
            const SizedBox(height: AppSizedBox.small),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: proteinProgress > 1 ? 1 : proteinProgress,
                backgroundColor: Colors.grey[300],
                color: proteinProgress > 1 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: AppSizedBox.large),
            // fat section
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.red),
                const SizedBox(width: AppSizedBox.medium),
                Text(
                  'Days Fat: $totalFat / ${goals.fat}',
                  style: const TextStyle(fontSize: AppFont.large),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: AppSizedBox.xxLarge),
                Text(
                  'Remaining: $remainingFat',
                  style: const TextStyle(fontSize: AppFont.medium),
                ),
              ],
            ),
            const SizedBox(height: AppSizedBox.small),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: proteinProgress > 1 ? 1 : proteinProgress,
                backgroundColor: Colors.grey[300],
                color: proteinProgress > 1 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: AppSizedBox.large),
            // carb section
            Row(
              children: [
                const Icon(Icons.grass, color: Colors.yellow),
                const SizedBox(width: AppSizedBox.medium),
                Text(
                  'Days Carb: $totalCarb / ${goals.carb}',
                  style: const TextStyle(fontSize: AppFont.large),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: AppSizedBox.xxLarge),
                Text(
                  'Remaining: $remainingCarb',
                  style: const TextStyle(fontSize: AppFont.medium),
                ),
              ],
            ),
            const SizedBox(height: AppSizedBox.small),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: proteinProgress > 1 ? 1 : proteinProgress,
                backgroundColor: Colors.grey[300],
                color: proteinProgress > 1 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: AppSizedBox.medium),
          ],
        ),
      ),
    );
  }
}
