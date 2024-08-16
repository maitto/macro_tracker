import 'package:calory_ai/models/data_entry.dart';
import 'package:calory_ai/models/goals.dart';
import 'package:calory_ai/models/meal_type.dart';
import 'package:calory_ai/view_models/home_page_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'mock_shared_preferences.dart';

@GenerateMocks([SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePageViewModel Tests', () {
    late HomePageViewModel viewModel;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      viewModel = HomePageViewModel(mockPrefs);
    });

    test('initializes with default values', () {
      expect(viewModel.entries, []);
      expect(viewModel.uniqueDates, []);
      expect(viewModel.goals.calorie, 0);
      expect(viewModel.goals.protein, 0);
      expect(viewModel.goals.fat, 0);
      expect(viewModel.goals.carb, 0);
    });

    test('loads goals from shared preferences', () async {
      when(mockPrefs.getInt(SharedPreferencesKeys.calorieGoal.name))
          .thenReturn(2000);
      when(mockPrefs.getInt(SharedPreferencesKeys.proteinGoal.name))
          .thenReturn(150);
      when(mockPrefs.getInt(SharedPreferencesKeys.fatGoal.name))
          .thenReturn(120);
      when(mockPrefs.getInt(SharedPreferencesKeys.carbGoal.name))
          .thenReturn(110);
      when(mockPrefs.getString(SharedPreferencesKeys.dataEntries.name))
          .thenReturn(null);

      viewModel.init();

      expect(viewModel.goals.calorie, 2000);
      expect(viewModel.goals.protein, 150);
      expect(viewModel.goals.fat, 120);
      expect(viewModel.goals.carb, 110);
    });

    test('stores new goals to shared preferences', () async {
      when(mockPrefs.getInt(SharedPreferencesKeys.calorieGoal.name))
          .thenReturn(2000);
      when(mockPrefs.getInt(SharedPreferencesKeys.proteinGoal.name))
          .thenReturn(150);
      when(mockPrefs.getInt(SharedPreferencesKeys.fatGoal.name))
          .thenReturn(120);
      when(mockPrefs.getInt(SharedPreferencesKeys.carbGoal.name))
          .thenReturn(110);
      when(mockPrefs.getString(SharedPreferencesKeys.dataEntries.name))
          .thenReturn(null);
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

      viewModel.init();

      viewModel
          .updateGoals(Goals(calorie: 2500, protein: 180, fat: 110, carb: 100));

      verify(mockPrefs.setInt(SharedPreferencesKeys.calorieGoal.name, 2500))
          .called(1);
      verify(mockPrefs.setInt(SharedPreferencesKeys.proteinGoal.name, 180))
          .called(1);
      verify(mockPrefs.setInt(SharedPreferencesKeys.fatGoal.name, 110))
          .called(1);
      verify(mockPrefs.setInt(SharedPreferencesKeys.carbGoal.name, 100))
          .called(1);
    });

    test('updates goals and notifies listeners', () async {
      bool isNotified = false;
      viewModel.addListener(() {
        isNotified = true;
      });

      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      viewModel.init();
      viewModel
          .updateGoals(Goals(calorie: 2500, protein: 180, fat: 110, carb: 100));
      expect(viewModel.goals.calorie, 2500);
      expect(viewModel.goals.protein, 180);
      expect(viewModel.goals.fat, 110);
      expect(viewModel.goals.carb, 100);
      expect(isNotified, true);
    });

    test('loads entries from shared preferences', () async {
      final dataEntryJson = jsonEncode([
        {
          'date': DateTime.now().toIso8601String(),
          'calories': 500,
          'protein': 30,
          'type': 'Lunch'
        }
      ]);

      when(mockPrefs.getString(SharedPreferencesKeys.dataEntries.name))
          .thenReturn(dataEntryJson);
      when(mockPrefs.getInt(any)).thenReturn(null);

      viewModel.init();

      expect(viewModel.entries.length, 1);
      expect(viewModel.entries[0].calories, 500);
      expect(viewModel.entries[0].protein, 30);
      expect(viewModel.entries[0].type, 'Lunch');
    });

    test('saves a new entry and notifies listeners', () async {
      bool isNotified = false;
      viewModel.addListener(() {
        isNotified = true;
      });

      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      viewModel.init();

      final entry = DataEntry(
          date: DateTime.now(),
          calories: 600,
          protein: 40,
          fat: 30,
          carb: 20,
          type: MealType.types.first);
      await viewModel.saveEntry(entry);

      expect(viewModel.entries.length, 1);
      expect(viewModel.entries[0].calories, 600);
      expect(viewModel.entries[0].protein, 40);
      expect(viewModel.entries[0].type, 'Snack');
      expect(isNotified, true);
    });

    test('deletes an entry and notifies listeners', () async {
      final dataEntryJson = jsonEncode([
        {
          'date': DateTime.now().toIso8601String(),
          'calories': 500,
          'protein': 30,
          'type': 'Meal'
        }
      ]);

      when(mockPrefs.getString(SharedPreferencesKeys.dataEntries.name))
          .thenReturn(dataEntryJson);
      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      viewModel.init();

      bool isNotified = false;
      viewModel.addListener(() {
        isNotified = true;
      });

      expect(viewModel.entries.length, 1);

      await viewModel.deleteEntry(0);

      expect(viewModel.entries.length, 0);
      expect(isNotified, true);
    });

    test('filters entries by date', () async {
      final now = DateTime.now();
      final dataEntryJson = jsonEncode([
        {
          'date': now.toIso8601String(),
          'calories': 500,
          'protein': 30,
          'type': 'Lunch'
        },
        {
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'calories': 600,
          'protein': 40,
          'type': 'Snack'
        }
      ]);

      when(mockPrefs.getString(SharedPreferencesKeys.dataEntries.name))
          .thenReturn(dataEntryJson);
      when(mockPrefs.getInt(any)).thenReturn(null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      viewModel.init();

      final todayEntries = viewModel.entriesForDate(now);
      final yesterdayEntries =
          viewModel.entriesForDate(now.subtract(const Duration(days: 1)));

      expect(todayEntries.length, 1);
      expect(todayEntries[0].calories, 500);
      expect(todayEntries[0].protein, 30);

      expect(yesterdayEntries.length, 1);
      expect(yesterdayEntries[0].calories, 600);
      expect(yesterdayEntries[0].protein, 40);
    });
  });
}
