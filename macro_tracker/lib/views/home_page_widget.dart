import 'package:macro_tracker/models/meal_type.dart';

import '../view_models/home_page_view_model.dart';
import '../utils/size_contants.dart';
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
                  goals: context.read<HomePageViewModel>().goals,
                  onGoalsChanged: (goals) {
                    context.read<HomePageViewModel>().updateGoals(goals);
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
          if (viewModel.uniqueDates.isNotEmpty) {
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
                        goals: viewModel.goals,
                      ),
                      Padding(
                        padding: EdgeInsetsAll.medium,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildEntriesByMealType(
                                entriesForDate, context, viewModel,),),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsAll.large,
                  child: Text(
                    'Add your goals from the settings icon',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBoxWithHeight.xxLarge,
                Padding(
                  padding: EdgeInsetsAll.large,
                  child: Text(
                    'Add entries by tapping the "+" button',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            );
          }
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
          onSave: (entry) {
            context.read<HomePageViewModel>().saveEntry(entry);
          },
        );
      },
    );
  }

  List<Widget> _buildEntriesByMealType(List<DataEntry> entries,
      BuildContext context, HomePageViewModel viewModel,) {
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
        int totalFat = entriesByMealType[mealType]!
            .fold(0, (sum, entry) => sum + entry.fat);
        int totalCarb = entriesByMealType[mealType]!
            .fold(0, (sum, entry) => sum + entry.carb);

        entryWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 40, thickness: 1),
              Text(
                'Totals for $mealType',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBoxWithHeight.small,
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBoxWithWidth.medium,
                  SizedBox(
                    width: 130.0,
                    child: Text(
                      'Calories: $totalCalories',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.fitness_center, color: Colors.blue),
                  SizedBoxWithWidth.medium,
                  Text(
                    'Protein: $totalProtein',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBoxWithHeight.small,
              Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.red),
                  SizedBoxWithWidth.medium,
                  SizedBox(
                    width: 130.0,
                    child: Text(
                      'Fat: $totalFat',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.grass, color: Colors.yellow),
                  SizedBoxWithWidth.medium,
                  Text(
                    'Carb: $totalCarb',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBoxWithHeight.large,
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
                SizedBoxWithHeight.medium,
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBoxWithHeight.small,
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange,),
                    SizedBoxWithWidth.medium,
                    SizedBox(
                      width: 130.0,
                      child: Text(
                        '${entry.calories}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.fitness_center, color: Colors.blue),
                    SizedBoxWithWidth.medium,
                    Text(
                      '${entry.protein}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                SizedBoxWithHeight.small,
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.red),
                    SizedBoxWithWidth.medium,
                    SizedBox(
                      width: 130.0,
                      child: Text(
                        '${entry.fat}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Icon(Icons.grass, color: Colors.yellow),
                    SizedBoxWithWidth.medium,
                    Text(
                      '${entry.carb}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                SizedBoxWithHeight.medium,
              ],
            ),
          );
        }).toList(),);
      }
    }

    return entryWidgets;
  }

  void _showDeleteMenu(
      BuildContext context, int entryIndex, HomePageViewModel viewModel,) {
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
