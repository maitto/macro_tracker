import 'package:calory_ai/models/data_entry.dart';
import 'package:calory_ai/models/meal_type.dart';
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
  final FocusNode _caloriesFocusNode = FocusNode();
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
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(
                  labelText: 'Fat',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: AppSizedBox.medium),
              TextFormField(
                controller: _carbController,
                decoration: const InputDecoration(
                  labelText: 'Carb',
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
