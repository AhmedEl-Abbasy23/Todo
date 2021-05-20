import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  // To be more easily when use this cubit in many place.
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  // To toggle between (BNB Items / Screens / AppBar titles).
  void changeIndex(index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase('todo.db', version: 1,
        // 1.create Database.
        onCreate: (database, version) {
      print('Database created');
      // 2.create Table.
      database
          .execute(
            "CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)",
          )
          .then((value) => print('Table created'))
          .catchError((error) {
        print('Error is: ${error.toString()}');
      });
    },
        // 3.open Database.
        onOpen: (database) {
      getFromDatabase(database);
      print('Database opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

// 1. Post to database.
  insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        emit(AppInsertDatabaseState());
        print('$value Inserted successfully');

        getFromDatabase(database);
      }).catchError((error) {
        print('Error is: ${error.toString()}');
      });
    });
  }

// 2. Get from database.
  void getFromDatabase(database) async {
    // To avoid duplicate data when get.
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseIsLoadingState());
    // Getting Database.
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
      print('Database gotten');
    });
  }

// 3. Update in database.
  void updateInDatabase({
    required String status,
    required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      emit(AppUpdateDatabaseState());
      print('Database updated');
      getFromDatabase(database);
    });
  }

// 4. Delete from database.
  void deleteFromDatabase({
    required int id,
  }) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getFromDatabase(database);
      emit(AppDeleteDatabaseState());
      print('Item on Database Deleted');
    });
  }

  // Floating action button icon.
  IconData fabIcon = Icons.edit;
  bool isBottomSheetShown = false;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
