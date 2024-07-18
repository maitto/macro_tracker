import '../size_contants.dart';
import 'package:flutter/material.dart';
import '../models/data_entry.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings_page_widget.dart';
import 'weekly_stats_page_widget.dart';
import 'modal_sheet_widget.dart';
import 'modal_sheet_ai_widget.dart';
import 'daily_stats_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DataEntry> _entries = [];
  List<DateTime> _uniqueDates = [];
  int _calorieGoal = 2800;
  int _proteinGoal = 180;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadData();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calorieGoal = prefs.getInt('calorieGoal') ?? 2800;
      _proteinGoal = prefs.getInt('proteinGoal') ?? 180;
    });
  }

  void _updateGoals(int calorieGoal, int proteinGoal) {
    setState(() {
      _calorieGoal = calorieGoal;
      _proteinGoal = proteinGoal;
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('dataEntries');
    if (dataString != null) {
      final List<dynamic> dataJson = jsonDecode(dataString);
      setState(() {
        _entries = dataJson.map((json) => DataEntry.fromJson(json)).toList();
        _entries.sort((a, b) =>
            b.date.compareTo(a.date)); // Sort entries in descending order
        _uniqueDates = _entries
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .toList();
        _uniqueDates
            .sort((a, b) => b.compareTo(a)); // Sort dates in descending order
      });
    }
  }

  Future<void> _saveData(int calories, int protein, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    setState(() {
      final newEntry = DataEntry(
          date: now, calories: calories, protein: protein, type: type);
      _entries.add(newEntry);
      _entries.sort((a, b) =>
          b.date.compareTo(a.date)); // Sort entries in descending order

      _uniqueDates = _entries
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toSet()
          .toList();
      _uniqueDates
          .sort((a, b) => b.compareTo(a)); // Sort dates in descending order
    });

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
  }

  Future<void> _deleteEntry(int entryIndex) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _entries.removeAt(entryIndex);
      _entries.sort((a, b) =>
          b.date.compareTo(a.date)); // Sort entries in descending order

      _uniqueDates = _entries
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toSet()
          .toList();
      _uniqueDates
          .sort((a, b) => b.compareTo(a)); // Sort dates in descending order
    });

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
  }

  Future<void> _showActionSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalSheetContent(
          onSave: (calories, protein, type) {
            _saveData(calories, protein, type);
          },
        );
      },
    );
  }

  Future<void> _showActionSheetAi(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalSheetContentAi(
          onSave: (calories, protein, type) {
            _saveData(calories, protein, type);
          },
        );
      },
    );
  }

  void _showDeleteMenu(BuildContext context, int entryIndex) {
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
                  _deleteEntry(entryIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
                    onGoalsChanged: _updateGoals,
                  ),
                ),
              );
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WeeklyStatsPage(entries: _entries),
                  ),
                );
              },
            ),
          ],
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _uniqueDates.length,
          reverse: true,
          itemBuilder: (context, index) {
            final date = _uniqueDates[index];
            final entriesForDate = _entries
                .where((e) =>
                    e.date.year == date.year &&
                    e.date.month == date.month &&
                    e.date.day == date.day)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DailyStats(
                      entries: entriesForDate,
                      calorieGoal: _calorieGoal,
                      proteinGoal: _proteinGoal),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildEntriesByMealType(entriesForDate, context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () => _showActionSheet(context),
            tooltip: 'Add Entry',
            child: const Icon(Icons.add),
          ),
          /*
          const SizedBox(height: AppSizedBox.medium),
          FloatingActionButton(
            onPressed: () => _showActionSheetAi(context),
            tooltip: 'Add Entry with AI',
            child: const Icon(Icons.chat),
          )*/
        ]));
  }

  List<Widget> _buildEntriesByMealType(
      List<DataEntry> entries, BuildContext context) {
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final Map<String, List<DataEntry>> entriesByMealType = {};

    for (var mealType in mealTypes) {
      entriesByMealType[mealType] =
          entries.where((e) => e.type == mealType).toList();
    }

    List<Widget> entryWidgets = [];
    for (var mealType in mealTypes) {
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
                  fontSize: 18,
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
          final entryIndex = _entries.indexOf(entry);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => _showDeleteMenu(context, entryIndex),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizedBox.medium),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 16,
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
}
