import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final timeController = TextEditingController();
  final dateController = TextEditingController();
  final titleController = TextEditingController();

  HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (BuildContext context, AppState state) {
          if (state is AppInsertIntoDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppState state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: const Text(
                "TODO App",
                style: TextStyle(fontSize: 25.0),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: Container(
                    padding: const EdgeInsetsDirectional.only(start: 20),
                    alignment: AlignmentDirectional.topStart,
                    child: Text(cubit.subTitles[cubit.currentIndex])),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit
                        .insertIntoDatabase(
                            title: titleController.text,
                            time: timeController.text,
                            date: dateController.text)
                        .then((value) {
                      cubit.closeBottomSheet();
                      titleController.clear();
                      timeController.clear();
                      dateController.clear();
                    });
                  }
                } else {
                  cubit.openBottomSheet();
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                        controller: titleController,
                                        inputType: TextInputType.text,
                                        label: "Task Title",
                                        suffix: Icons.title,
                                        validate: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return "Title cannot be empty!";
                                          }
                                          return null;
                                        }),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                        controller: timeController,
                                        inputType: TextInputType.datetime,
                                        label: "Task Time",
                                        suffix: Icons.watch_later_outlined,
                                        validate: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return "Time cannot be empty!";
                                          }
                                          return null;
                                        },
                                        onTap: () => showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            ).then((value) =>
                                                timeController.text = value!
                                                    .format(context)
                                                    .toString())),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    defaultFormField(
                                        controller: dateController,
                                        inputType: TextInputType.datetime,
                                        label: "Task Date",
                                        suffix: Icons.date_range,
                                        validate: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return "Date cannot be empty!";
                                          }
                                          return null;
                                        },
                                        onTap: () => showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(
                                                  const Duration(days: 6000)),
                                            ).then((value) =>
                                                dateController.text =
                                                    DateFormat.yMMMd()
                                                        .format(value!))),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .closed
                      .then((value) {
                    cubit.closeBottomSheet();
                  });
                }
              },
              elevation: 20.0,
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: "Archived"),
              ],
            ),
            body: ConditionalBuilder(
              condition: state is! AppLoadingDataFromDatabaseState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
