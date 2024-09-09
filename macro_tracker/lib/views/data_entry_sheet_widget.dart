import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macro_tracker/models/data_entry.dart';
import 'package:macro_tracker/models/meal_type.dart';

import '../utils/size_contants.dart';

class DataEntrySheetContent extends StatefulWidget {
  const DataEntrySheetContent({super.key, required this.onSave});

  final Function(DataEntry) onSave;

  @override
  DataEntrySheetState createState() => DataEntrySheetState();
}

class DataEntrySheetState extends State<DataEntrySheetContent> {
  final TextEditingController _caloriesController =
      TextEditingController(text: '');
  final TextEditingController _proteinController =
      TextEditingController(text: '');
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  String _selectedType = MealType.types.first;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbController.dispose();
    super.dispose();
  }

  void _saveData() {
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int protein = int.tryParse(_proteinController.text) ?? 0;
    final int fat = int.tryParse(_fatController.text) ?? 0;
    final int carb = int.tryParse(_carbController.text) ?? 0;

    if (!(calories == 0 && protein == 0 && fat == 0 && carb == 0)) {
      final now = DateTime.now();
      final entry = DataEntry(
        date: now,
        calories: calories,
        protein: protein,
        fat: fat,
        carb: carb,
        type: _selectedType,
      );
      widget.onSave(entry);
      Navigator.of(context).pop();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsetsAll.medium,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Enter Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBoxWithHeight.medium,
              DataEntryTextFormField(
                controller: _caloriesController,
                labelText: 'Calories',
                autofocus: true,
              ),
              SizedBoxWithHeight.medium,
              DataEntryTextFormField(
                controller: _proteinController,
                labelText: 'Protein',
              ),
              SizedBoxWithHeight.medium,
              DataEntryTextFormField(
                controller: _fatController,
                labelText: 'Fat',
              ),
              SizedBoxWithHeight.medium,
              DataEntryTextFormField(
                controller: _carbController,
                labelText: 'Carb',
              ),
              SizedBoxWithHeight.medium,
              SegmentedButton<String>(
                segments: MealType.types,
                selected: _selectedType,
                onSelectionChanged: (String newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
              SizedBoxWithHeight.large,
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataEntryTextFormField extends StatelessWidget {
  const DataEntryTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String labelText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class SegmentedButton<T> extends StatelessWidget {
  final List<T> segments;
  final T selected;
  final ValueChanged<T> onSelectionChanged;

  const SegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: segments.map((T segment) => segment == selected).toList(),
      onPressed: (int index) {
        onSelectionChanged(segments[index]);
      },
      children: segments
          .map(
            (T segment) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              child: Text(segment.toString()),
            ),
          )
          .toList(),
    );
  }
}
