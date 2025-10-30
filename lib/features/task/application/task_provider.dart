import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:personal_task_manager/features/task/application/task_state.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = Hive.box<Task>('tasks');
  return TaskRepository(box);
});

final taskStateProvider = StateNotifierProvider<TaskListNotifier, TaskState>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskListNotifier(repository);
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(taskStateProvider).filteredTasks;
});

class TaskListNotifier extends StateNotifier<TaskState> {
  final TaskRepository repository;

  TaskListNotifier(this.repository) : super(const TaskState());

  void loadTasks() {
    try {
      state = state.copyWith(isLoading: true);
      final tasks = repository.getTasks();
      state = state.copyWith(tasks: tasks, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        tasks: [],
        isLoading: false,
      );
    }
  }

  Future<void> addTask(Task task) async {
    try {
      state = state.copyWith(isLoading: true);
      await repository.addTask(task);
      state = state.copyWith(
        tasks: [...state.tasks, task],
        error: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> updateTask(int index, Task task) async {
    try {
      state = state.copyWith(isLoading: true);
      await repository.updateTask(index, task);
      final newTasks = List<Task>.from(state.tasks);
      newTasks[index] = task;
      state = state.copyWith(tasks: newTasks, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> deleteTask(int index) async {
    try {
      state = state.copyWith(isLoading: true);
      await repository.deleteTask(index);
      final newTasks = List<Task>.from(state.tasks);
      newTasks.removeAt(index);
      state = state.copyWith(tasks: newTasks, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
