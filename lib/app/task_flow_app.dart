import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/tasks/repositories/task_repository.dart';
import '../features/tasks/views/screens/task_shell_screen.dart';
import 'theme/app_theme.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key, required this.repository});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return Provider<TaskRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Task Flow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const TaskShellScreen(),
      ),
    );
  }
}
