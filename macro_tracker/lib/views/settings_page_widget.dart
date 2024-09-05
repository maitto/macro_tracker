import 'package:macro_tracker/models/goals.dart';

import '../utils/size_contants.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Goals goals;
  final Function(Goals) onGoalsChanged;

  const SettingsPage(
      {super.key, required this.goals, required this.onGoalsChanged,});

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
    _calorieGoalController.text =
        widget.goals.calorie == 0 ? '' : widget.goals.calorie.toString();

    _proteinGoalController.text =
        widget.goals.protein == 0 ? '' : widget.goals.protein.toString();

    _fatGoalController.text =
        widget.goals.fat == 0 ? '' : widget.goals.fat.toString();

    _carbGoalController.text =
        widget.goals.carb == 0 ? '' : widget.goals.carb.toString();
  }

  void _saveGoalsTapped() {
    final int calorieGoal = int.tryParse(_calorieGoalController.text) ?? 0;
    final int proteinGoal = int.tryParse(_proteinGoalController.text) ?? 0;
    final int fatGoal = int.tryParse(_fatGoalController.text) ?? 0;
    final int carbGoal = int.tryParse(_carbGoalController.text) ?? 0;
    final Goals goals = Goals(
        calorie: calorieGoal,
        protein: proteinGoal,
        fat: fatGoal,
        carb: carbGoal,);

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
        padding: EdgeInsetsAll.medium,
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
            SizedBoxWithHeight.xLarge,
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
