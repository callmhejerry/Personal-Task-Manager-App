import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_task_manager/features/task/application/add_edit_task_provider.dart';
import 'package:personal_task_manager/features/task/data/task_repository.dart';
import 'package:personal_task_manager/models/task.dart';

import 'add_edit_task_provider_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('AddEditTaskService', () {
    late AddEditTaskService service;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = MockTaskRepository();
      service = AddEditTaskService(mockRepository);
    });

    test('saveTask calls addTask when index is null', () async {
      final task = Task(title: 'Test', description: 'Test Description');

      when(mockRepository.addTask(task)).thenAnswer((_) async {});

      await service.saveTask(task);

      verify(mockRepository.addTask(task)).called(1);
      verifyNever(mockRepository.updateTask(any, any));
    });

    test('saveTask calls updateTask when index is provided', () async {
      final task = Task(title: 'Test', description: 'Test Description');
      const index = 0;

      when(mockRepository.updateTask(index, task)).thenAnswer((_) async {});

      await service.saveTask(task, index: index);

      verify(mockRepository.updateTask(index, task)).called(1);
      verifyNever(mockRepository.addTask(any));
    });
  });
}
