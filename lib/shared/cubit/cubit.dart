import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../modules/archived_tasks_screen.dart';
import '../../modules/done_tasks_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int _currentIndex = 0;
  late Database _database;
  IconData _fabIcon = Icons.edit;
  bool _isBottomSheetShown = false;
  final List<Map> _newTasks = [];
  final List<Map> _doneTasks = [];
  final List<Map> _archivedTasks = [];

  int get currentIndex => _currentIndex;
  IconData get fabIcon => _fabIcon;
  bool get isBottomSheetShown => _isBottomSheetShown;
  List<Map> get newTasks => _newTasks;
  List<Map> get doneTasks => _doneTasks;
  List<Map> get archivedTasks => _archivedTasks;

  final List<String> subTitles = ["New Tasks", "Done Tasks", "Archived Tasks"];

  final List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  void openBottomSheet() {
    _isBottomSheetShown = true;
    _fabIcon = Icons.add;
    emit(AppShowBottomSheetState());
  }

  void closeBottomSheet() {
    _isBottomSheetShown = false;
    _fabIcon = Icons.edit;
    emit(AppCloseBottomSheetState());
  }

  void changeIndex(int index) {
    _currentIndex = index;
    emit(AppChangeBottomNavBarState());
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
            .then((value) {
          print("Table tasks Successfully Created");
          emit(AppCreateDatabaseState());
        }).catchError((error) => print("Error: $error"));
      },
      onOpen: (db) => print("Database Opened ${db.path}"),
    ).then((db) {
      print("openDatabase finished ${db.getVersion()}");
      _database = db;
      emit(AppOpenDatabaseState());
      getAllDataFromDatabase();
    });
  }

  void getAllDataFromDatabase() {
    _newTasks.clear();
    _doneTasks.clear();
    _archivedTasks.clear();

    emit(AppLoadingDataFromDatabaseState());

    _database.rawQuery("SELECT * FROM tasks").then((value) {
      for (var element in value) {
        if (element["status"] == "new") {
          _newTasks.add(element);
        } else if (element["status"] == "done") {
          _doneTasks.add(element);
        } else {
          _archivedTasks.add(element);
        }
      }

      emit(AppGetDataFromDatabaseState());
    });
  }

  Future insertIntoDatabase(
      {required String title,
      required String time,
      required String date}) async {
    return await _database.transaction((txn) => txn
            .rawInsert("INSERT INTO tasks (title, time, date, status) "
                "VALUES ('$title', '$time', '$date', 'new')")
            .then((value) {
          print("$value inserted successfully");
          emit(AppInsertIntoDatabaseState());
          getAllDataFromDatabase();
        }).catchError((error) => print(
                "An error occurred while inserting records, Error: $error")));
  }

  void updateData(String newStatus, int id) {
    _database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        [newStatus, id]).then((value) {
      emit(AppUpdateDatabaseState());
      getAllDataFromDatabase();
    });
  }
}
