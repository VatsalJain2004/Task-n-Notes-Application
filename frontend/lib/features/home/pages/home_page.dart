import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/login_page.dart';
import 'package:frontend/features/home/cubit/add_new_task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/widgets/common_empty_state.dart';
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
    print('Welcome to Home Page');

    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    context.read<AddNewTaskCubit>().getAllTasks(token: user.user.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('My Tasks'),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Are you sure you Want to Logout ?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().logout();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.logout_outlined,
              size: 25,
            )),
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
                .where((elem) =>
                    DateFormat('dd/MM/yyyy').format(elem.dueAt) ==
                    DateFormat('dd/MM/yyyy').format(selectedDate))
                .toList();
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
                  child: tasks.isEmpty
                      ? CommonEmptyState(dateTime: selectedDate)
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return GestureDetector(
                              onLongPress: () {
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
                                      border: BoxBorder.all(color: Colors.black, width: 2),
                                      shape: BoxShape.circle,
                                      color: strengthenColor(task.color, 1),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          DateFormat.jm().format(task.dueAt),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () => Navigator.push(
                                                context, AddNewTaskPage.route(task: task)),
                                            icon: Icon(Icons.edit))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
