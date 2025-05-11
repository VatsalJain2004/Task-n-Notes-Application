import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/utils.dart';

part 'add_new_task_state.dart';

class AddNewTaskCubit extends Cubit<AddNewTaskState> {
  AddNewTaskCubit() : super(AddNewTaskInitial());
  final taskRemoteRepository = TaskRemoteRepository();
  final taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color color,
    required DateTime dueAt,
    required String token,
    required String uid,
  }) async {
    try {
      emit(AddNewTaskLoading());
      final taskModel = await taskRemoteRepository.createTask(
        uid: uid,
          title: title,
          description: description,
          hexColor: rgbToHex(color),
          dueAt: dueAt,
          token: token
      );

      await taskLocalRepository.insertTask(taskModel);

      emit(AddNewTaskSuccess(taskModel));
    } catch (error) {
      emit(AddNewTaskError('createNewTasks ==> ${error.toString()}'));
    }
  }

  Future<void> getAllTasks({required String token,}) async {
    try {
      emit(AddNewTaskLoading());
      final tasks = await taskRemoteRepository.getTasks(token: token);
      emit(GetTasksSuccess(tasks));
    }
    catch (error) {
      emit(AddNewTaskError('getAllTasks ==> ${error.toString()}'));
    }
  }
}
