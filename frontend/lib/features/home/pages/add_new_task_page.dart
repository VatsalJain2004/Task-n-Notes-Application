import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/add_new_task_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';
import 'package:intl/intl.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AddNewTaskPage(),
      );
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  Color selectedColor = Colors.deepOrange.shade100;

  void createNewTask() async {
    if (formKey.currentState!.validate()) {
      AuthLoggedIn user = context.read<AuthCubit>().state as AuthLoggedIn;

      await context.read<AddNewTaskCubit>().createNewTask(
        uid: user.user.id,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            color: selectedColor,
            dueAt: selectedDate,
            token: user.user.token,
          );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final _selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 90)));

              if (_selectedDate != null) {
                setState(() {
                  selectedDate = _selectedDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('dd-MM-yy').format(selectedDate),
                style: TextStyle(fontSize: 13, fontFamily: 'Cera Pro', fontWeight: FontWeight.w200),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: BlocConsumer<AddNewTaskCubit, AddNewTaskState>(
          listener: (context, state) {
            if (state is AddNewTaskError) {
              print('AddNewTaskError : --> ${state.error}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
            } else if (state is AddNewTaskSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Task Added Successfully, Yay!')));
              Navigator.pushAndRemoveUntil(context, HomePage.route(), (_) => false);
            }
          },
          builder: (context, state) {
            if (state is AddNewTaskLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Task Title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title Cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Task Description',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description Cannot be empty';
                        }
                        return null;
                      },
                      maxLines: 5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ColorPicker(
                      heading: Text(
                        'Select Color',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                      ),
                      subheading: Text(
                        'Select Shade',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                      ),
                      pickersEnabled: {
                        ColorPickerType.wheel: true,
                      },
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      color: selectedColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: createNewTask,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Cera Pro',
                            fontWeight: FontWeight.w300,
                            color: selectedColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
