import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_task_manager/models/task.dart';

class HiveService {
  final HiveInterface _hive;

  HiveService({HiveInterface? hive}) : _hive = hive ?? Hive;

  Future<void> init() async {
    await _hive.initFlutter();
    _hive.registerAdapter(TaskAdapter());
    await _hive.openBox<Task>('tasks');
  }
}
