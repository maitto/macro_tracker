class WeeklyStat {
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfWeekDaysWithData;
  final int averageCalories;
  final int averageProtein;

  WeeklyStat(
      {required this.startDate,
      required this.endDate,
      required this.numberOfWeekDaysWithData,
      required this.averageCalories,
      required this.averageProtein});
}
