import 'package:flutter/material.dart';

import 'app/task_flow_app.dart';
import 'features/tasks/data/draft_storage_service.dart';
import 'features/tasks/data/local_database_service.dart';
import 'features/tasks/repositories/task_repository.dart';
import 'features/tasks/repositories/task_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = LocalDatabaseService();
  await databaseService.initialize();

  final draftStorageService = await DraftStorageService.create();
  final repository = TaskRepositoryImpl(
    databaseService: databaseService,
    draftStorageService: draftStorageService,
  );

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return TaskFlowApp(repository: repository);
  }
}
