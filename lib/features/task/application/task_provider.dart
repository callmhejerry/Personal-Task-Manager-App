import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = Hive.box<Task>('tasks');
  return TaskRepository(box);
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered tasks provider
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return tasks;
  }

  return tasks.where((task) {
    return task.title.toLowerCase().contains(searchQuery) ||
        task.description.toLowerCase().contains(searchQuery);
  }).toList();
});

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repository);
});

class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskRepository _repository;

  TaskListNotifier(this._repository) : super([]) {
    state = _repository.getTasks();
  }

  void addTask(Task task) {
    _repository.addTask(task);
    state = [...state, task];
  }

  void updateTask(int index, Task task) {
    _repository.updateTask(index, task);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) task else state[i],
    ];
  }

  void deleteTask(int index) {
    _repository.deleteTask(index);
    state = [...state]..removeAt(index);
  }
}
