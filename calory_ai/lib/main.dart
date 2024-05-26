import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<void> _saveData(int calories, int protein) async {
    final prefs = await SharedPreferences.getInstance();
    final newEntry = DataEntry(date: DateTime.now(), calories: calories, protein: protein);
    setState(() {
      _entries.add(newEntry);
    });
    final String dataString = jsonEncode(_entries.map((entry) => entry.toJson()).toList());
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${entry.date.toLocal().toString().split(' ')[0]}'),
                        Text('Calories: ${entry.calories}'),
                        Text('Protein: ${entry.protein} g'),
                        SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionSheet(context),
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
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
                      labelText: 'Protein (g)',
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

class DataEntry {
  final DateTime date;
  final int calories;
  final int protein;

  DataEntry({required this.date, required this.calories, required this.protein});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'calories': calories,
    'protein': protein,
  };

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      date: DateTime.parse(json['date']),
      calories: json['calories'],
      protein: json['protein'],
    );
  }
}