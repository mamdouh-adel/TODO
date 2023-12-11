import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';

import '../modules/archived_tasks_screen.dart';
import '../modules/done_tasks_screen.dart';
import '../shared/components/constants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;

  final List<String> _subTitles = ["New Tasks", "Done Tasks", "Archived Tasks"];

  late Database database;

  final List<Widget> _screens = [
    NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  IconData fabIcon = Icons.edit;

  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var titleController = TextEditingController();

  bool isBottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text(_subTitles[_currentIndex])),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertIntoDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text)
                  .then((value) {
                Navigator.pop(context);
                isBottomSheetShown = false;
                setState(() {
                  fabIcon = Icons.edit;
                });
                titleController.clear();
                timeController.clear();
                dateController.clear();
              });
            }
          } else {
            isBottomSheetShown = true;
            setState(() {
              fabIcon = Icons.add;
            });
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
                                      ).then((value) => timeController.text =
                                          value!.format(context).toString())),
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
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 6000)),
                                      ).then((value) => dateController.text =
                                          DateFormat.yMMMd().format(value!))),
                            ],
                          ),
                        ),
                      ),
                    ))
                .closed
                .then((value) {
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
          }
        },
        elevation: 20.0,
        child: Icon(fabIcon),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
        condition: tasks.isNotEmpty,
        builder: (context) => _screens[_currentIndex],
        fallback: (context) => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<String> getName() async {
    throw ("Unknown error!!!");
    return "Zezo............";
  }

  void createDatabase() {
    openDatabase(
      "todo.db",
      version: 1,
      onCreate: (database, version) {
        print("Database Successfully Created");
        database
            .execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT,"
                " date TEXT, time TEXT, status TEXT) ")
            .then((value) => print("Table tasks Successfully Created"))
            .catchError((error) => print("Error: $error"));
      },
      onOpen: (db) => print("Database Opened ${db.path}"),
    ).then((db) {
      print("openDatabase finished ${db.getVersion()}");
      database = db;
      getAllDataFromDatabase(database).then((value) {
        tasks = value;
        print(tasks);
      });
    });
  }

  Future<List<Map>> getAllDataFromDatabase(Database database) async {
    return await database.rawQuery("SELECT * FROM tasks");
  }

  Future insertIntoDatabase(
      {required String title,
      required String time,
      required String date}) async {
    return await database.transaction((txn) => txn
        .rawInsert("INSERT INTO tasks (title, time, date, status) "
            "VALUES ('$title', '$time', '$date', 'new')")
        .then((value) => print("$value inserted successfully"))
        .catchError((error) =>
            print("An error occurred while inserting records, Error: $error")));
  }
}
