import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'settings_page.dart';
import 'data_entry.dart';
import 'modal_sheet_content.dart';
import 'modal_sheet_content_ai.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('fi', ''), // FI
        // Add other supported locales here
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // Use system theme mode (light/dark)
      home: const MyHomePage(title: 'Calory AI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                    padding: const EdgeInsets.all(16.0),
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
          const SizedBox(height: 10),
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
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 10),
                  Text(
                    '$mealType calories: $totalCalories',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    '$mealType protein: $totalProtein',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 25),
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
                const SizedBox(height: 10),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    const SizedBox(width: 10),
                    Text(
                      '${entry.calories}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      '${entry.protein}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }).toList());
      }
    }

    return entryWidgets;
  }
}

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

class WeeklyStatsPage extends StatelessWidget {
  final List<DataEntry> entries;

  const WeeklyStatsPage({required this.entries, Key? key}) : super(key: key);

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
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      const SizedBox(width: 10),
                      Text(
                        'Average Daily Calories: ${weekStats['averageCalories']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        'Average Daily Protein: ${weekStats['averageProtein']}',
                        style: const TextStyle(fontSize: 18),
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
    int daysInWeek = 0;

    for (var entry in sortedEntries) {
      if (entry.date.isAfter(weekEndDate)) {
        if (daysInWeek > 0) {
          weeklyStats.add({
            'startDate': weekStartDate,
            'endDate': weekEndDate,
            'averageCalories': (totalCalories / daysInWeek).round(),
            'averageProtein': (totalProtein / daysInWeek).round(),
          });
        }

        weekStartDate = _findPreviousMonday(entry.date);
        weekEndDate = weekStartDate.add(const Duration(days: 6));
        totalCalories = 0;
        totalProtein = 0;
        daysInWeek = 0;
      }

      totalCalories += entry.calories;
      totalProtein += entry.protein;
      daysInWeek += 1;
    }

    if (daysInWeek > 0) {
      weeklyStats.add({
        'startDate': weekStartDate,
        'endDate': weekEndDate,
        'averageCalories': (totalCalories / daysInWeek).round(),
        'averageProtein': (totalProtein / daysInWeek).round(),
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
