import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/data_entry.dart';

class HomePageViewModel extends ChangeNotifier {
  List<DataEntry> _entries = [];
  List<DateTime> _uniqueDates = [];
  int _calorieGoal = 0;
  int _proteinGoal = 0;
  late PageController _pageController;

  List<DataEntry> get entries => _entries;
  List<DateTime> get uniqueDates => _uniqueDates;
  int get calorieGoal => _calorieGoal;
  int get proteinGoal => _proteinGoal;
  PageController get pageController => _pageController;
  SharedPreferences? _sharedPreferences;

  HomePageViewModel([SharedPreferences? sharedPreferences]) {
    _sharedPreferences = sharedPreferences;
  }

  void init() {
    _pageController = PageController(initialPage: 0);
    _loadEntries();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    _calorieGoal = prefs.getInt('calorieGoal') ?? 0;
    _proteinGoal = prefs.getInt('proteinGoal') ?? 0;
    notifyListeners();
  }

  void updateGoals(int calorieGoal, int proteinGoal) async {
    _calorieGoal = calorieGoal;
    _proteinGoal = proteinGoal;
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    prefs.setInt('calorieGoal', calorieGoal);
    prefs.setInt('proteinGoal', proteinGoal);
    notifyListeners();
  }

  Future<void> _loadEntries() async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('dataEntries');
    if (dataString != null) {
      final List<dynamic> dataJson = jsonDecode(dataString);
      _entries = dataJson.map((json) => DataEntry.fromJson(json)).toList();
      _entries.sort((a, b) => b.date.compareTo(a.date));
      _uniqueDates = _entries
          .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
          .toSet()
          .toList();
      _uniqueDates.sort((a, b) => b.compareTo(a));
      notifyListeners();
    }
  }

  Future<void> saveEntry(int calories, int protein, String type) async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    final now = DateTime.now();

    final newEntry = DataEntry(
      date: now,
      calories: calories,
      protein: protein,
      type: type,
    );

    _entries.add(newEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    _uniqueDates = _entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    _uniqueDates.sort((a, b) => b.compareTo(a));

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
    notifyListeners();
  }

  Future<void> deleteEntry(int entryIndex) async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    _entries.removeAt(entryIndex);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    _uniqueDates = _entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    _uniqueDates.sort((a, b) => b.compareTo(a));

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString('dataEntries', dataString);
    notifyListeners();
  }

  List<DataEntry> entriesForDate(DateTime date) {
    return _entries
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }
}
