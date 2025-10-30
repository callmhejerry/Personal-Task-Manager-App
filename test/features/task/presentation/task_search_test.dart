import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/presentation/task_list_screen.dart';
import 'package:personal_task_manager/models/task.dart';

import '../application/task_provider_test.mocks.dart';

void main() {
  group('Task Search', () {
    late MockTaskRepository mockTaskRepository;
    final tasks = [
      Task(title: 'Buy groceries', description: 'Get milk and bread'),
      Task(title: 'Call mom', description: 'Ask about the recipe'),
      Task(title: 'Clean house', description: 'Vacuum and dust'),
    ];

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      when(mockTaskRepository.getTasks()).thenReturn(tasks);
    });

    testWidgets('shows search field in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('filters tasks based on title search', (tester) async {
      late TaskListNotifier taskNotifier;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
            taskStateProvider.overrideWith((ref) {
              taskNotifier = TaskListNotifier(mockTaskRepository);
              return taskNotifier;
            }),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      // Wait for initial state to be ready
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Initially shows all tasks
      expect(find.text(tasks[0].title), findsOneWidget);
      expect(find.text(tasks[1].title), findsOneWidget);
      expect(find.text(tasks[2].title), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'call');
      await tester.pump();

      // Should only show matching task
      expect(find.text('Call mom'), findsOneWidget);
      expect(find.text('Buy groceries'), findsNothing);
      expect(find.text('Clean house'), findsNothing);
    });

    testWidgets('filters tasks based on description search', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      // Enter search query matching description
      await tester.enterText(find.byType(TextField), 'milk');
      await tester.pump();

      // Should only show task with matching description
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Call mom'), findsNothing);
      expect(find.text('Clean house'), findsNothing);
    });

    testWidgets('shows empty state when no tasks match search', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      // Enter search query with no matches
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      // Should show empty state
      expect(find.text('No tasks yet!'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('search is case-insensitive', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
          ],
          child: const MaterialApp(home: TaskListScreen()),
        ),
      );

      // Enter search query in different case
      await tester.enterText(find.byType(TextField), 'CALL');
      await tester.pump();

      // Should find the task despite case difference
      expect(find.text('Call mom'), findsOneWidget);
    });
  });
}
