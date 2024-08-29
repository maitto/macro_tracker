import 'package:macro_tracker/models/goals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/data_entry.dart';

enum SharedPreferencesKeys {
  calorieGoal,
  proteinGoal,
  fatGoal,
  carbGoal,
  dataEntries
}

class HomePageViewModel extends ChangeNotifier {
  List<DataEntry> get entries => _entries;
  List<DateTime> get uniqueDates => _uniqueDates;
  Goals get goals => _goals;

  PageController get pageController => _pageController;

  List<DataEntry> _entries = [];
  List<DateTime> _uniqueDates = [];
  Goals _goals = Goals(calorie: 0, protein: 0, fat: 0, carb: 0);
  late PageController _pageController;
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
    _goals.calorie = prefs.getInt(SharedPreferencesKeys.calorieGoal.name) ?? 0;
    _goals.protein = prefs.getInt(SharedPreferencesKeys.proteinGoal.name) ?? 0;
    _goals.fat = prefs.getInt(SharedPreferencesKeys.fatGoal.name) ?? 0;
    _goals.carb = prefs.getInt(SharedPreferencesKeys.carbGoal.name) ?? 0;

    notifyListeners();
  }

  void updateGoals(Goals goals) async {
    _goals = goals;
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    prefs.setInt(SharedPreferencesKeys.calorieGoal.name, goals.calorie);
    prefs.setInt(SharedPreferencesKeys.proteinGoal.name, goals.protein);
    prefs.setInt(SharedPreferencesKeys.fatGoal.name, goals.fat);
    prefs.setInt(SharedPreferencesKeys.carbGoal.name, goals.carb);

    notifyListeners();
  }

  Future<void> _loadEntries() async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
    final String? dataString =
        prefs.getString(SharedPreferencesKeys.dataEntries.name);
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

  Future<void> saveEntry(DataEntry newEntry) async {
    final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();

    _entries.add(newEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    _uniqueDates = _entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    _uniqueDates.sort((a, b) => b.compareTo(a));

    final String dataString =
        jsonEncode(_entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(SharedPreferencesKeys.dataEntries.name, dataString);
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
    await prefs.setString(SharedPreferencesKeys.dataEntries.name, dataString);
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
