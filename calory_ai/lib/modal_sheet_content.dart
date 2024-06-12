import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModalSheetContent extends StatefulWidget {
  const ModalSheetContent({super.key, required this.onSave});

  final Function(int, int) onSave;

  @override
  _ModalSheetContentState createState() => _ModalSheetContentState();
}

class _ModalSheetContentState extends State<ModalSheetContent> {
  final FocusNode _caloriesFocusNode = FocusNode();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();

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
    final int? calories = int.tryParse(_caloriesController.text);
    final int? protein = int.tryParse(_proteinController.text);

    if (calories != null && protein != null) {
      widget.onSave(calories, protein);
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
