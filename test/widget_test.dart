import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/task_provider.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/main.dart';
import 'package:personal_task_manager/models/task.dart';
import 'package:personal_task_manager/services/hive_service.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([HiveService, TaskRepository])
void main() {
  group('MyApp', () {
    late MockHiveService mockHiveService;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockHiveService = MockHiveService();
      mockTaskRepository = MockTaskRepository();

      when(mockHiveService.init()).thenAnswer((_) async => {});
      when(mockTaskRepository.getTasks()).thenReturn([]);
    });

    testWidgets('App starts', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockTaskRepository),
          ],
          child: const MyApp(),
        ),
      );
      expect(find.text('No tasks yet!'), findsOneWidget);
    });
  });
}