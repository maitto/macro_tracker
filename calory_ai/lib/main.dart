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
  int _calorieGoal = 2800;
  int _proteinGoal = 180;

  @override
  void initState() {
    super.initState();
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
      });
    }
  }

  Future<void> _saveData(int calories, int protein, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    bool entryExists = false;

    setState(() {
      for (var entry in _entries) {
        if (entry.date.year == now.year &&
            entry.date.month == now.month &&
            entry.date.day == now.day &&
            entry.type == type) {
          entry.calories += calories;
          entry.protein += protein;
          entryExists = true;
          break;
        }
      }

      if (!entryExists) {
        final newEntry = DataEntry(
            date: now, calories: calories, protein: protein, type: type);
        _entries.add(newEntry);
      }
    });

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
  }

  Future<void> _deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _entries.removeAt(index);
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
      body: Column(
        children: [
          DailyStats(entries: _entries), // Add the daily stats widget
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[_entries.length - 1 - index];
                final formattedDate =
                    DateFormat('EEEE, MMMM d, y').format(entry.date);
                final formattedTime = DateFormat('h:mm a').format(entry.date);
                final double calorieProgress =
                    (_calorieGoal > 0) ? entry.calories / _calorieGoal : 0.0;
                final double proteinProgress =
                    (_proteinGoal > 0) ? entry.protein / _proteinGoal : 0.0;

                return Dismissible(
                  key: Key(entry.date.toIso8601String()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteEntry(_entries.length - 1 - index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$formattedTime - $formattedDate (${entry.type})',
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
                              'Calories: ${entry.calories} / $_calorieGoal',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: calorieProgress > 1 ? 1 : calorieProgress,
                          backgroundColor: Colors.grey[300],
                          color:
                              calorieProgress > 1 ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.fitness_center,
                                color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              'Protein: ${entry.protein} / $_proteinGoal',
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
                        const Divider(height: 40, thickness: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  const DailyStats({required this.entries, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    int totalCalories = 0;
    int totalProtein = 0;

    for (var entry in entries) {
      if (entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day) {
        totalCalories += entry.calories;
        totalProtein += entry.protein;
      }
    }

    final formattedDate = DateFormat('EEEE, MMMM d, y').format(now);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Stats ($formattedDate)',
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
                  'Total Calories: $totalCalories',
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
                  'Total Protein: $totalProtein',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
