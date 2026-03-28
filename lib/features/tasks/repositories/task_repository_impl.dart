import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../data/draft_storage_service.dart';
import '../data/local_database_service.dart';
import '../models/task_draft_model.dart';
import '../models/task_model.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required LocalDatabaseService databaseService,
    required DraftStorageService draftStorageService,
  }) : _databaseService = databaseService,
       _draftStorageService = draftStorageService;

  final LocalDatabaseService _databaseService;
  final DraftStorageService _draftStorageService;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final database = await _databaseService.database;
    final rows = await database.query(
      'tasks',
      orderBy: 'due_date ASC, created_at ASC',
    );

    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final database = await _databaseService.database;
    final now = DateTime.now();
    final task = TaskModel(
      id: now.microsecondsSinceEpoch.toRadixString(16),
      title: draft.title.trim(),
      description: draft.description.trim(),
      dueDate: _normalizedDate(draft.dueDate!),
      status: draft.status,
      blockedByTaskId: draft.blockedByTaskId,
      createdAt: now,
      updatedAt: now,
    );

    await database.insert('tasks', task.toMap());
    return task;
  }

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final database = await _databaseService.database;
    final rows = await database.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Task not found');
    }

    final existing = TaskModel.fromMap(rows.first);
    final updated = existing.copyWith(
      title: draft.title.trim(),
      description: draft.description.trim(),
      dueDate: _normalizedDate(draft.dueDate!),
      status: draft.status,
      blockedByTaskId: draft.blockedByTaskId,
      updatedAt: DateTime.now(),
    );

    await database.update(
      'tasks',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    final database = await _databaseService.database;
    final tasks = await fetchTasks();
    final dependents = tasks
        .where((task) => task.blockedByTaskId == id)
        .toList();

    final batch = database.batch();
    for (final task in dependents) {
      batch.update(
        'tasks',
        task.copyWith(blockedByTaskId: null, updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
    batch.delete('tasks', where: 'id = ?', whereArgs: [id]);
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveDraft(TaskDraftModel draft) {
    return _draftStorageService.save(draft);
  }

  @override
  TaskDraftModel? loadDraft() {
    return _draftStorageService.load();
  }

  @override
  Future<void> clearDraft() {
    return _draftStorageService.clear();
  }

  DateTime _normalizedDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
