import 'package:hive/hive.dart';
import 'package:personal_task_manager/models/task.dart';

class TaskRepository {
  final Box<Task> _taskBox;

  TaskRepository(this._taskBox);

  List<Task> getTasks() {
    return _taskBox.values.toList();
  }

  Future<void> addTask(Task task) async {
    await _taskBox.add(task);
  }

  Future<void> updateTask(int index, Task task) async {
    await _taskBox.putAt(index, task);
  }

  Future<void> deleteTask(int index) async {
    await _taskBox.deleteAt(index);
  }
}
