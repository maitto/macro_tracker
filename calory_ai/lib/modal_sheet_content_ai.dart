import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModalSheetContentAi extends StatefulWidget {
  const ModalSheetContentAi(
      {super.key,
      required this.onSave,
      this.initialCalories,
      this.initialProtein,
      this.initialType});

  final Function(int, int, String) onSave;
  final int? initialCalories;
  final int? initialProtein;
  final String? initialType;

  @override
  _ModalSheetContentState createState() => _ModalSheetContentState();
}

class _ModalSheetContentState extends State<ModalSheetContentAi> {
  final FocusNode _caloriesFocusNode = FocusNode();
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  String _selectedType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.initialCalories?.toString() ?? '');
    _proteinController =
        TextEditingController(text: widget.initialProtein?.toString() ?? '');
    _selectedType = widget.initialType ?? 'Breakfast';
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
    final int? calories = int.tryParse(_caloriesController.text);
    final int? protein = int.tryParse(_proteinController.text);

    if (calories != null && protein != null) {
      widget.onSave(calories, protein, _selectedType);
      Navigator.of(context).pop();
    } else {
      // Handle validation error, e.g., show a message to the user
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
          padding: const EdgeInsets.all(16.0), // Add padding to all sides
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Enter Details', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: _mealTypes,
                selected: _selectedType,
                onSelectionChanged: (String newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(segment.toString()),
              ))
          .toList(),
    );
  }
}
