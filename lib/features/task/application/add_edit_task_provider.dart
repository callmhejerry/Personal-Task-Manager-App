import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

final addEditTaskProvider = Provider(
  (ref) => AddEditTaskService(ref.watch(taskRepositoryProvider)),
);

class AddEditTaskService {
  final TaskRepository _repository;

  AddEditTaskService(this._repository);

  Future<void> saveTask(Task task, {int? index}) async {
    if (index != null) {
      await _repository.updateTask(index, task);
    } else {
      await _repository.addTask(task);
    }
  }
}

// Provider to track the current editing state
final taskEditingProvider = StateProvider<Task?>((ref) => null);
