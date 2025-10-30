import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/presentation/task_list_screen.dart';
import 'package:personal_task_manager/models/task.dart';

import '../application/task_provider_test.mocks.dart';

void main() {
  group('TaskListScreen', () {
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      when(mockTaskRepository.getTasks()).thenReturn([]);
    });

    testWidgets('TaskListScreen shows empty state when there are no tasks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      expect(find.text('No tasks yet!'), findsOneWidget);
    });

    testWidgets('TaskListScreen shows a list of tasks', (
      WidgetTester tester,
    ) async {
      final tasks = [
        Task(title: 'Task 1', description: 'Description 1'),
        Task(title: 'Task 2', description: 'Description 2'),
      ];

      when(mockTaskRepository.getTasks()).thenReturn(tasks);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when delete button is pressed', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Task'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this task?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deletes task when confirmed in dialog', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.deleteTask(0)).called(1);
    });

    testWidgets('does not delete task when cancelled in dialog', (
      WidgetTester tester,
    ) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(mockTaskRepository.deleteTask(0));
    });

    testWidgets('can delete task by swipe', (WidgetTester tester) async {
      when(
        mockTaskRepository.getTasks(),
      ).thenReturn([Task(title: 'Task 1', description: 'Description 1')]);
      when(mockTaskRepository.deleteTask(0)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskListProvider.overrideWith(
              (ref) => TaskListNotifier(ref.read(taskRepositoryProvider)),
            ),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      await tester.drag(find.text('Task 1'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockTaskRepository.deleteTask(0)).called(1);
    });
  });
}
