import '../utils/size_contants.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final int calorieGoal;
  final int proteinGoal;
  final Function(int, int) onGoalsChanged;

  const SettingsPage(
      {required this.calorieGoal,
      required this.proteinGoal,
      required this.onGoalsChanged,
      super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final TextEditingController _calorieGoalController = TextEditingController();
  final TextEditingController _proteinGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calorieGoalController.text = widget.calorieGoal.toString();
    _proteinGoalController.text = widget.proteinGoal.toString();
  }

  void _saveGoalsTapped() {
    final int calorieGoal = int.parse(_calorieGoalController.text);
    final int proteinGoal = int.parse(_proteinGoalController.text);
    widget.onGoalsChanged(calorieGoal, proteinGoal);
    Navigator.of(context).pop();
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
