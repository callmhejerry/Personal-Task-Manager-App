import 'package:hive/hive.dart';
import 'package:personal_task_manager/models/task.dart';

class TaskException implements Exception {
  final String message;
  TaskException(this.message);

  @override
  String toString() => message;
}

class TaskRepository {
  final Box<Task> _taskBox;

  TaskRepository(this._taskBox);

  List<Task> getTasks() {
    try {
      return _taskBox.values.toList();
    } catch (e) {
      throw TaskException('Failed to load tasks: ${e.toString()}');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _taskBox.add(task);
    } catch (e) {
      throw TaskException('Failed to add task: ${e.toString()}');
    }
  }

  Future<void> updateTask(int index, Task task) async {
    try {
      if (index < 0 || index >= _taskBox.length) {
        throw TaskException('Invalid task index: $index');
      }
      await _taskBox.putAt(index, task);
    } catch (e) {
      throw TaskException('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(int index) async {
    try {
      if (index < 0 || index >= _taskBox.length) {
        throw TaskException('Invalid task index: $index');
      }
      await _taskBox.deleteAt(index);
    } catch (e) {
      throw TaskException('Failed to delete task: ${e.toString()}');
    }
  }
}
