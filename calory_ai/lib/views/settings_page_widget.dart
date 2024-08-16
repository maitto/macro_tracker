import 'package:calory_ai/models/goals.dart';

import '../utils/size_contants.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Goals goals;
  final Function(Goals) onGoalsChanged;

  const SettingsPage(
      {super.key, required this.goals, required this.onGoalsChanged});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController _calorieGoalController = TextEditingController();
  final TextEditingController _proteinGoalController = TextEditingController();
  final TextEditingController _fatGoalController = TextEditingController();
  final TextEditingController _carbGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calorieGoalController.text = widget.goals.calorie.toString();
    _proteinGoalController.text = widget.goals.protein.toString();
    _fatGoalController.text = widget.goals.fat.toString();
    _carbGoalController.text = widget.goals.carb.toString();
  }

  void _saveGoalsTapped() {
    final int calorieGoal = int.parse(_calorieGoalController.text);
    final int proteinGoal = int.parse(_proteinGoalController.text);
    final int fatGoal = int.parse(_fatGoalController.text);
    final int carbGoal = int.parse(_carbGoalController.text);
    final Goals goals = Goals(
        calorie: calorieGoal,
        protein: proteinGoal,
        fat: fatGoal,
        carb: carbGoal);

    widget.onGoalsChanged(goals);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _calorieGoalController.dispose();
    _proteinGoalController.dispose();
    _fatGoalController.dispose();
    _carbGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
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
            TextField(
              controller: _fatGoalController,
              decoration: const InputDecoration(labelText: 'Fat Goal'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _carbGoalController,
              decoration: const InputDecoration(labelText: 'Carb Goal'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizedBox.xLarge),
            ElevatedButton(
              onPressed: () {
                _saveGoalsTapped();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
