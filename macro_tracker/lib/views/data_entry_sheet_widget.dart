import 'package:macro_tracker/models/data_entry.dart';
import 'package:macro_tracker/models/meal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _fatController = TextEditingController(text: '');
  final TextEditingController _carbController = TextEditingController(text: '');
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
          type: _selectedType,);
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
              CaloriesTextFormField(caloriesController: _caloriesController),
              SizedBoxWithHeight.medium,
              ProteinTextFormField(proteinController: _proteinController),
              SizedBoxWithHeight.medium,
              FatTextFormField(fatController: _fatController),
              SizedBoxWithHeight.medium,
              CarbTextFormField(carbController: _carbController),
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

class CarbTextFormField extends StatelessWidget {
  const CarbTextFormField({
    super.key,
    required TextEditingController carbController,
  }) : _carbController = carbController;

  final TextEditingController _carbController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _carbController,
      decoration: const InputDecoration(
        labelText: 'Carb',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class FatTextFormField extends StatelessWidget {
  const FatTextFormField({
    super.key,
    required TextEditingController fatController,
  }) : _fatController = fatController;

  final TextEditingController _fatController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _fatController,
      decoration: const InputDecoration(
        labelText: 'Fat',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class ProteinTextFormField extends StatelessWidget {
  const ProteinTextFormField({
    super.key,
    required TextEditingController proteinController,
  }) : _proteinController = proteinController;

  final TextEditingController _proteinController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _proteinController,
      decoration: const InputDecoration(
        labelText: 'Protein',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class CaloriesTextFormField extends StatelessWidget {
  const CaloriesTextFormField({
    super.key,
    required TextEditingController caloriesController,
  }) : _caloriesController = caloriesController;

  final TextEditingController _caloriesController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: _caloriesController,
      decoration: const InputDecoration(
        labelText: 'Calories',
        border: OutlineInputBorder(),
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
          .map((T segment) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                child: Text(segment.toString()),
              ),)
          .toList(),
    );
  }
}
