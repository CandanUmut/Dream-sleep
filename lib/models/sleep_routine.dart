class SleepRoutineStep {
  const SleepRoutineStep({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  final String title;
  final String description;
  final bool isCompleted;

  SleepRoutineStep copyWith({bool? isCompleted}) {
    return SleepRoutineStep(
      title: title,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
