import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/application/task_state.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

import 'task_provider_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskListNotifier', () {
    late ProviderContainer container;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      when(mockRepository.getTasks()).thenReturn([]);

      container = ProviderContainer(
        overrides: [taskRepositoryProvider.overrideWithValue(mockRepository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has empty tasks list', () {
      final state = container.read(taskStateProvider);
      expect(state.tasks, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.searchQuery, isEmpty);
    });

    test('addTask adds a task to the state', () async {
      final task = Task(title: 'Test Task', description: 'Test Description');
      when(mockRepository.addTask(task)).thenAnswer((_) async => true);

      await container.read(taskStateProvider.notifier).addTask(task);

      final state = container.read(taskStateProvider);
      expect(state.tasks, [task]);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
    });

    test('updateTask updates a task in the state', () async {
      final initialTask = Task(title: 'Initial', description: 'Initial');
      container.read(taskStateProvider.notifier).state = TaskState(
        tasks: [initialTask],
      );

      final updatedTask = Task(title: 'Updated', description: 'Updated');
      when(
        mockRepository.updateTask(0, updatedTask),
      ).thenAnswer((_) async => true);

      await container
          .read(taskStateProvider.notifier)
          .updateTask(0, updatedTask);

      final state = container.read(taskStateProvider);
      expect(state.tasks, [updatedTask]);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
    });

    test('deleteTask removes a task from the state', () async {
      final task = Task(title: 'Test', description: 'Test');
      container.read(taskStateProvider.notifier).state = TaskState(
        tasks: [task],
      );

      when(mockRepository.deleteTask(0)).thenAnswer((_) async => true);

      await container.read(taskStateProvider.notifier).deleteTask(0);

      final state = container.read(taskStateProvider);
      expect(state.tasks, isEmpty);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
    });

    test('filtered tasks returns matching tasks', () async {
      final tasks = [
        Task(title: 'Work Task', description: 'Do work'),
        Task(title: 'Home Task', description: 'Clean house'),
        Task(title: 'Another Work', description: 'More work'),
      ];
      container.read(taskStateProvider.notifier).state = TaskState(
        tasks: tasks,
      );

      container.read(taskStateProvider.notifier).updateSearchQuery('work');

      final filteredTasks = container.read(filteredTasksProvider);
      expect(filteredTasks.length, 2);
      expect(
        filteredTasks.every(
          (task) =>
              task.title.toLowerCase().contains('work') ||
              task.description.toLowerCase().contains('work'),
        ),
        isTrue,
      );
    });

    test('error handling sets error state', () async {
      final task = Task(title: 'Test', description: 'Test');
      when(mockRepository.addTask(task)).thenThrow(Exception('Test error'));

      await container.read(taskStateProvider.notifier).addTask(task);

      final state = container.read(taskStateProvider);
      expect(state.error, 'Test error');
      expect(state.isLoading, isFalse);
    });
  });
}
