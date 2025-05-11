import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/add_new_task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(builder: (context) => const HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<AddNewTaskCubit>().getAllTasks(token: user.user.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, AddNewTaskPage.route());
            },
            icon: Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: BlocBuilder<AddNewTaskCubit, AddNewTaskState>(
        builder: (context, state) {
          if (state is AddNewTaskLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is AddNewTaskError) {
            return Center(
              child: Text(state.error),
            );
          }
          if (state is GetTasksSuccess) {
            // print('state is GetTasksSuccess --> ${state.tasks}');
            final tasks = state.tasks
              .where(
                (elem) =>
                  DateFormat('d').format(elem.dueAt) == DateFormat('d').format(selectedDate) &&
                  elem.dueAt.month == selectedDate.month &&
                  elem.dueAt.year == selectedDate.year
              ).toList();
            return Column(
              children: [
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return GestureDetector(
                          onLongPress: (){
                            setState(() {
                              tasks.removeAt(index);
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: TaskCard(
                                  color: task.color,
                                  headerText: task.title,
                                  descriptionText: task.description,
                                ),
                              ),
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: strengthenColor(task.color, 0.69),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(DateFormat.jm().format(task.dueAt),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: strengthenColor(task.color, 0.69),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                ),
              ],
            );
          }
          return const SizedBox(
            height: 10,
          );
        },
      ),
    );
  }
}
