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
      expect(viewModel.calorieGoal, 0);
      expect(viewModel.proteinGoal, 0);
    });

    test('loads goals from shared preferences', () async {
      when(mockPrefs.getInt('calorieGoal')).thenReturn(2000);
      when(mockPrefs.getInt('proteinGoal')).thenReturn(150);
      when(mockPrefs.getString('dataEntries')).thenReturn(null);

      viewModel.init();

      expect(viewModel.calorieGoal, 2000);
      expect(viewModel.proteinGoal, 150);
    });

    test('stores new goals to shared preferences', () async {
      when(mockPrefs.getInt('calorieGoal')).thenReturn(2000);
      when(mockPrefs.getInt('proteinGoal')).thenReturn(150);
      when(mockPrefs.getString('dataEntries')).thenReturn(null);
      when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

      viewModel.init();

      viewModel.updateGoals(2500, 180);

      verify(mockPrefs.setInt('calorieGoal', 2500)).called(1);
      verify(mockPrefs.setInt('proteinGoal', 180)).called(1);
    });

    test('updates goals and notifies listeners', () async {
      bool isNotified = false;
      viewModel.addListener(() {
        isNotified = true;
      });

      viewModel.updateGoals(2500, 200);

      expect(viewModel.calorieGoal, 2500);
      expect(viewModel.proteinGoal, 200);
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

      when(mockPrefs.getString('dataEntries')).thenReturn(dataEntryJson);
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

      await viewModel.saveEntry(600, 40, 'Snack');

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

      when(mockPrefs.getString('dataEntries')).thenReturn(dataEntryJson);
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

      when(mockPrefs.getString('dataEntries')).thenReturn(dataEntryJson);
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
