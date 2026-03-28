enum TaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  const TaskStatus(this.label);

  final String label;

  String get dbValue => name;

  static TaskStatus fromDb(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => TaskStatus.todo,
    );
  }
}
