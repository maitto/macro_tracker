import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'settings_page.dart';
import 'data_entry.dart';

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
  late PageController _pageController;
  int _calorieGoal = 2800;
  int _proteinGoal = 180;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
    _loadGoals();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

      if (_entries.isNotEmpty) {
        _pageController.jumpToPage(_entries.length - 1);
      }
    }
  }

  Future<void> _saveData(int calories, int protein) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    bool entryExists = false;

    setState(() {
      for (var entry in _entries) {
        if (entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day) {
          entry.calories += calories;
          entry.protein += protein;
          entryExists = true;
          break;
        }
      }

      if (!entryExists) {
        final newEntry =
            DataEntry(date: today, calories: calories, protein: protein);
        _entries.add(newEntry);
      }
    });

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalSheetContent(
          onSave: (calories, protein) {
            _saveData(calories, protein);
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
          WeeklyStats(entries: _entries), // Add the weekly stats widget
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final formattedDate =
                    DateFormat('EEEE, MMMM d, y').format(entry.date);
                final double calorieProgress =
                    (_calorieGoal > 0) ? entry.calories / _calorieGoal : 0.0;
                final double proteinProgress =
                    (_proteinGoal > 0) ? entry.protein / _proteinGoal : 0.0;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$formattedDate',
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
                        color: calorieProgress > 1 ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            'Protein: ${entry.protein} g / $_proteinGoal g',
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

class WeeklyStats extends StatelessWidget {
  final List<DataEntry> entries;

  const WeeklyStats({required this.entries, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    int totalCalories = 0;
    int totalProtein = 0;

    for (var entry in entries) {
      if (entry.date.isAfter(startOfWeek) &&
          entry.date.isBefore(endOfWeek.add(Duration(days: 1)))) {
        totalCalories += entry.calories;
        totalProtein += entry.protein;
      }
    }

    final formattedStartOfWeek = DateFormat('MMM d').format(startOfWeek);
    final formattedEndOfWeek = DateFormat('MMM d').format(endOfWeek);

    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Stats ($formattedStartOfWeek - $formattedEndOfWeek)',
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
                  'Total Protein: $totalProtein g',
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

class ModalSheetContent extends StatefulWidget {
  const ModalSheetContent({super.key, required this.onSave});

  final Function(int, int) onSave;

  @override
  _ModalSheetContentState createState() => _ModalSheetContentState();
}

class _ModalSheetContentState extends State<ModalSheetContent> {
  final FocusNode _caloriesFocusNode = FocusNode();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caloriesFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _caloriesFocusNode.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _saveData() {
    final int? calories = int.tryParse(_caloriesController.text);
    final int? protein = int.tryParse(_proteinController.text);

    if (calories != null && protein != null) {
      widget.onSave(calories, protein);
      Navigator.of(context).pop();
    } else {
      // Handle validation error, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Enter Details', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  TextFormField(
                    focusNode: _caloriesFocusNode,
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Protein',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: const Text('Save'),
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
