import 'task_model.dart';
import 'task_status.dart';

class TaskDraftModel {
  const TaskDraftModel({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedByTaskId,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? blockedByTaskId;

  factory TaskDraftModel.empty() {
    return const TaskDraftModel(
      title: '',
      description: '',
      dueDate: null,
      status: TaskStatus.todo,
      blockedByTaskId: null,
    );
  }

  factory TaskDraftModel.fromTask(TaskModel task) {
    return TaskDraftModel(
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: task.status,
      blockedByTaskId: task.blockedByTaskId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.dbValue,
      'blockedByTaskId': blockedByTaskId,
    };
  }

  factory TaskDraftModel.fromJson(Map<String, Object?> json) {
    return TaskDraftModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate']! as String),
      status: TaskStatus.fromDb(
        json['status'] as String? ?? TaskStatus.todo.dbValue,
      ),
      blockedByTaskId: json['blockedByTaskId'] as String?,
    );
  }
}
