import 'package:flutter/material.dart';
import 'package:todo_app/shared/bloc_observer.dart';
import 'package:bloc/bloc.dart';
import 'layouts/todo_layout.dart';

void main() {
  // To show cubit status.
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}
