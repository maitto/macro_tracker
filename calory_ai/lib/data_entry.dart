class DataEntry {
  DateTime date;
  int calories;
  int protein;

  DataEntry(
      {required this.date, required this.calories, required this.protein});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'calories': calories,
        'protein': protein,
      };

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      date: DateTime.parse(json['date']),
      calories: json['calories'],
      protein: json['protein'],
    );
  }
}
