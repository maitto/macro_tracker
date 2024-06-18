import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(int, int) onGoalsChanged;

  const SettingsPage({required this.onGoalsChanged, super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _calorieGoalController = TextEditingController();
  final TextEditingController _proteinGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calorieGoalController.text =
          (prefs.getInt('calorieGoal') ?? 2800).toString();
      _proteinGoalController.text =
          (prefs.getInt('proteinGoal') ?? 180).toString();
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final int calorieGoal = int.parse(_calorieGoalController.text);
    final int proteinGoal = int.parse(_proteinGoalController.text);

    await prefs.setInt('calorieGoal', calorieGoal);
    await prefs.setInt('proteinGoal', proteinGoal);

    widget.onGoalsChanged(calorieGoal, proteinGoal);
  }

  @override
  void dispose() {
    _calorieGoalController.dispose();
    _proteinGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _calorieGoalController,
              decoration: const InputDecoration(labelText: 'Calorie Goal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _proteinGoalController,
              decoration: const InputDecoration(labelText: 'Protein Goal'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveGoals();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
