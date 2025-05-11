import 'dart:convert';
import 'dart:io';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required DateTime dueAt,
    required String token,
    required String uid,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'hexColor': hexColor,
          'dueAt': dueAt.toIso8601String(),
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return TaskModel.fromJson(res.body);
    } catch (error) {
      try {
        TaskModel taskModel = TaskModel(
          id: const Uuid().v4(),
          uid: uid,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      }
      catch (error) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('getTasks token ==> ${token}');

      final decoded = jsonDecode(res.body);
      final listOfTasks = decoded is List ? decoded : decoded['tasks'];
      print('getTasks listOfTasks ==> ${listOfTasks}');

      List<TaskModel> tasksLists = [];

      for (dynamic elem in listOfTasks) {
        tasksLists.add(TaskModel.fromMap(elem));
      }
      print('tasksList ==? ${tasksLists}');
      await taskLocalRepository.insertTasks(tasksLists);
      print('taskLocalRepository.insertTasks(tasksLists) ==> ${tasksLists.toList()}');

      return tasksLists;
    } catch (error) {
      final tasks = await taskLocalRepository.getTasks();

      if (tasks.isNotEmpty) {
        return tasks;
      }
      rethrow; // aka throw e
    }
  }
}
