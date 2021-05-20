import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_app/shared/components/components.dart';

import 'package:intl/intl.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeLayout extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          // To be more easily when use this cubit in many place.
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              elevation: 5,
              backgroundColor: Colors.black,
              title: Text(
                cubit.titles[cubit.currentIndex],
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.amber,
                ),
              ),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              child: Icon(
                cubit.fabIcon,
                color: Colors.amber,
              ),
              backgroundColor: Colors.black,
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: _titleController.text,
                      date: _dateController.text,
                      time: _timeController.text,
                    );
                    // To empty (TextFormFields) after insert.
                    _titleController.text = '';
                    _dateController.text = '';
                    _timeController.text = '';
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          width: double.infinity,
                          height: 330.0,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.amber[600],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Expanded(
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      defaultTextFormFiled(
                                        controller: _titleController,
                                        label: 'Title',
                                        prefix: Icons.title,
                                        onTap: () {},
                                        validate: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter task title';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10.0),
                                      defaultTextFormFiled(
                                        controller: _dateController,
                                        inputType: TextInputType.datetime,
                                        label: 'Date',
                                        prefix: Icons.date_range,
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2050),
                                          ).then((value) => {
                                                _dateController.text =
                                                    DateFormat.yMMMd()
                                                        .format(value!)
                                              });
                                        },
                                        validate: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter task date';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10.0),
                                      defaultTextFormFiled(
                                        controller: _timeController,
                                        inputType: TextInputType.datetime,
                                        label: 'Time',
                                        prefix: Icons.watch_later_outlined,
                                        onTap: () {
                                          showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          ).then((value) {
                                            _timeController.text = value!
                                                .format(context)
                                                .toString();
                                          });
                                        },
                                        validate: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter task time';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        elevation: 25.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });
                  // else => if bottom sheet is shown.
                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.amber[600],
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'Archive',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
