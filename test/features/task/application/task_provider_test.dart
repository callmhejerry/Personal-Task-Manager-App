import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

import 'task_provider_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskListNotifier', () {
    late TaskListNotifier notifier;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      when(mockRepository.getTasks()).thenReturn([]);
      notifier = TaskListNotifier(mockRepository);
    });

    test('initial state is an empty list', () {
      expect(notifier.state, []);
    });

    test('addTask adds a task to the state', () {
      final task = Task(title: 'Test Task', description: 'Test Description');
      when(mockRepository.addTask(task)).thenAnswer((_) async => true);

      notifier.addTask(task);

      expect(notifier.state, [task]);
    });

    test('updateTask updates a task in the state', () {
      final initialTask = Task(title: 'Initial', description: 'Initial');
      notifier.state = [initialTask];

      final updatedTask = Task(title: 'Updated', description: 'Updated');
      when(
        mockRepository.updateTask(0, updatedTask),
      ).thenAnswer((_) async => true);

      notifier.updateTask(0, updatedTask);

      expect(notifier.state, [updatedTask]);
    });

    test('deleteTask removes a task from the state', () {
      final task = Task(title: 'Test', description: 'Test');
      notifier.state = [task];

      when(mockRepository.deleteTask(0)).thenAnswer((_) async => true);

      notifier.deleteTask(0);

      expect(notifier.state, []);
    });
  });
}
