import 'task_status.dart';

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedByTaskId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedByTaskId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    Object? blockedByTaskId = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedByTaskId: blockedByTaskId == _sentinel
          ? this.blockedByTaskId
          : blockedByTaskId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TaskModel.fromMap(Map<String, Object?> map) {
    return TaskModel(
      id: map['id']! as String,
      title: map['title']! as String,
      description: map['description']! as String,
      dueDate: DateTime.parse(map['due_date']! as String),
      status: TaskStatus.fromDb(map['status']! as String),
      blockedByTaskId: map['blocked_by_task_id'] as String?,
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.dbValue,
      'blocked_by_task_id': blockedByTaskId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

const Object _sentinel = Object();
