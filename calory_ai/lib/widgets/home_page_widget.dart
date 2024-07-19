import 'package:calory_ai/models/meal_type.dart';

import '../view_models/home_page_view_model.dart';
import '../size_contants.dart';
import 'package:flutter/material.dart';
import '../models/data_entry.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'settings_page_widget.dart';
import 'weekly_stats_page_widget.dart';
import 'data_entry_sheet_widget.dart';
import 'daily_stats_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsPage(
                  onGoalsChanged: (calorieGoal, proteinGoal) {
                    context
                        .read<HomePageViewModel>()
                        .updateGoals(calorieGoal, proteinGoal);
                  },
                ),
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Consumer<HomePageViewModel>(
                    builder: (context, viewModel, child) {
                      return WeeklyStatsPage(entries: viewModel.entries);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HomePageViewModel>(
        builder: (context, viewModel, child) {
          return PageView.builder(
            controller: viewModel.pageController,
            itemCount: viewModel.uniqueDates.length,
            reverse: true,
            itemBuilder: (context, index) {
              final date = viewModel.uniqueDates[index];
              final entriesForDate = viewModel.entriesForDate(date);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DailyStats(
                      entries: entriesForDate,
                      calorieGoal: viewModel.calorieGoal,
                      proteinGoal: viewModel.proteinGoal,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildEntriesByMealType(
                            entriesForDate, context, viewModel),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showActionSheet(context),
            tooltip: 'Add Entry',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DataEntrySheetContent(
          onSave: (calories, protein, type) {
            context.read<HomePageViewModel>().saveEntry(calories, protein, type);
          },
        );
      },
    );
  }

  List<Widget> _buildEntriesByMealType(List<DataEntry> entries,
      BuildContext context, HomePageViewModel viewModel) {
    final Map<String, List<DataEntry>> entriesByMealType = {};

    for (var mealType in MealType.types) {
      entriesByMealType[mealType] =
          entries.where((e) => e.type == mealType).toList();
    }

    List<Widget> entryWidgets = [];
    for (var mealType in MealType.types) {
      if (entriesByMealType[mealType]!.isNotEmpty) {
        int totalCalories = entriesByMealType[mealType]!
            .fold(0, (sum, entry) => sum + entry.calories);
        int totalProtein = entriesByMealType[mealType]!
            .fold(0, (sum, entry) => sum + entry.protein);

        entryWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 40, thickness: 1),
              Text(
                mealType,
                style: TextStyle(
                  fontSize: AppFont.large,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSizedBox.small),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: AppSizedBox.medium),
                  Text(
                    '$mealType calories: $totalCalories',
                    style: const TextStyle(fontSize: AppFont.medium),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.blue),
                  const SizedBox(width: AppSizedBox.medium),
                  Text(
                    '$mealType protein: $totalProtein',
                    style: const TextStyle(fontSize: AppFont.medium),
                  ),
                ],
              ),
              const SizedBox(height: AppSizedBox.large),
            ],
          ),
        );

        entryWidgets.addAll(entriesByMealType[mealType]!.map((entry) {
          Locale locale = Localizations.localeOf(context);
          DateFormat dateFormat = DateFormat.Hm(locale.toString());
          final formattedTime = dateFormat.format(entry.date);
          final entryIndex = viewModel.entries.indexOf(entry);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => _showDeleteMenu(context, entryIndex, viewModel),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizedBox.medium),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: AppFont.medium,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizedBox.small),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    const SizedBox(width: AppSizedBox.medium),
                    Text(
                      '${entry.calories}',
                      style: const TextStyle(fontSize: AppFont.medium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizedBox.small),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.blue),
                    const SizedBox(width: AppSizedBox.medium),
                    Text(
                      '${entry.protein}',
                      style: const TextStyle(fontSize: AppFont.medium),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizedBox.medium),
              ],
            ),
          );
        }).toList());
      }
    }

    return entryWidgets;
  }

  void _showDeleteMenu(
      BuildContext context, int entryIndex, HomePageViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Entry'),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.deleteEntry(entryIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
