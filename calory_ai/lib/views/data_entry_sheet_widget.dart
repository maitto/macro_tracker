import 'package:calory_ai/models/data_entry.dart';
import 'package:calory_ai/models/meal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/size_contants.dart';

class DataEntrySheetContent extends StatefulWidget {
  const DataEntrySheetContent(
      {super.key,
      required this.onSave,
      this.initialCalories,
      this.initialProtein,
      this.initialType});

  final Function(DataEntry) onSave;
  final int? initialCalories;
  final int? initialProtein;
  final String? initialType;

  @override
  DataEntrySheetState createState() => DataEntrySheetState();
}

class DataEntrySheetState extends State<DataEntrySheetContent> {
  final FocusNode _caloriesFocusNode = FocusNode();
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.initialCalories?.toString() ?? '');
    _proteinController =
        TextEditingController(text: widget.initialProtein?.toString() ?? '');
    _selectedType = widget.initialType ?? MealType.types.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caloriesFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _caloriesFocusNode.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _saveData() {
    final int calories = int.tryParse(_caloriesController.text) ?? 0;
    final int protein = int.tryParse(_proteinController.text) ?? 0;

    if (!(calories == 0 && protein == 0)) {
      final now = DateTime.now();
      final entry = DataEntry(
          date: now,
          calories: calories,
          protein: protein,
          fat: fat,
          carb: carb,
          type: _selectedType);
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
          padding: const EdgeInsets.all(
              AppSpacing.medium), // Add padding to all sides
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Enter Details',
                  style: TextStyle(fontSize: AppFont.xLarge)),
              const SizedBox(height: AppSizedBox.medium),
              TextFormField(
                focusNode: _caloriesFocusNode,
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppSizedBox.medium),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppSizedBox.medium),
              SegmentedButton<String>(
                segments: MealType.types,
                selected: _selectedType,
                onSelectionChanged: (String newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
              const SizedBox(height: AppSizedBox.xLarge),
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
              ))
          .toList(),
    );
  }
}
