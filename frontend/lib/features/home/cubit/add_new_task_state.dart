part of 'add_new_task_cubit.dart';

sealed class AddNewTaskState {
  const AddNewTaskState();
}

final class AddNewTaskInitial extends AddNewTaskState {}

final class AddNewTaskLoading extends AddNewTaskState {}

final class AddNewTaskError extends AddNewTaskState {
  final String error;
  const AddNewTaskError(this.error);
}

final class AddNewTaskSuccess extends AddNewTaskState {
  final TaskModel taskModel;
  const AddNewTaskSuccess(this.taskModel);
}

final class GetTasksSuccess extends AddNewTaskState {
  final List<TaskModel> tasks;
  const GetTasksSuccess(this.tasks);
}
