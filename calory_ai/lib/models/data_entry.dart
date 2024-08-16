class DataEntry {
  final DateTime date;
  final String type;
  int calories;
  int protein;
  int fat;
  int carb;

  DataEntry(
      {required this.date,
      required this.calories,
      required this.protein,
      required this.fat,
      required this.carb,
      required this.type});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type,
        'calories': calories,
        'protein': protein,
      };

  factory DataEntry.fromJson(Map<String, dynamic> json) {
    return DataEntry(
      date: DateTime.parse(json['date']),
      type: json['type'],
      calories: json['calories'],
      protein: json['protein'],
      fat: json['fat'],
      carb: json['carb']
    );
  }
}
