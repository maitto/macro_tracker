import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'settings_page.dart';
import 'data_entry.dart';
import 'modal_sheet_content.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    bool entryExists = false;

    setState(() {
      final newEntry = DataEntry(
          date: now, calories: calories, protein: protein, type: type);
      _entries.add(newEntry);

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

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _entries.removeAt(index);
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

  void _showDeleteMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Entry'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteEntry(index);
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
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
          final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

          return GestureDetector(
            onLongPress: () => _showDeleteMenu(context, index),
            child: SingleChildScrollView(
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
                      children: entriesForDate.map((entry) {
                        final formattedTime =
                            DateFormat('h:mm a').format(entry.date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$formattedTime - ${entry.type}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Text(
                                  'Calories: ${entry.calories}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.fitness_center,
                                    color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(
                                  'Protein: ${entry.protein}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const Divider(height: 40, thickness: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionSheet(context),
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
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

    final formattedDate =
        DateFormat('EEEE, MMMM d, y').format(entries.first.date);

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
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: calorieProgress > 1 ? 1 : calorieProgress,
              backgroundColor: Colors.grey[300],
              color: calorieProgress > 1 ? Colors.red : Colors.orange,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: proteinProgress > 1 ? 1 : proteinProgress,
              backgroundColor: Colors.grey[300],
              color: proteinProgress > 1 ? Colors.red : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
