import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultTextFormFiled({
  required TextEditingController controller,
  required String? Function(String?) validate,
  required String label,
  required IconData prefix,
  required Function onTap,
  TextInputType inputType = TextInputType.text,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validate,
      onTap: () => onTap(),
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          prefix,
          color: Colors.amber[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.amber,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35.0,
              backgroundColor: Colors.black,
              child: Text(
                model['time'],
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    model['date'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.0),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateInDatabase(
                  status: 'done',
                  id: model['id'],
                );
              },
              icon: Icon(
                AppCubit.get(context).currentIndex > 0
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.amber,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateInDatabase(
                  status: 'archive',
                  id: model['id'],
                );
              },
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteFromDatabase(id: model['id']);
      },
    );

Widget tasksBuilder({required tasks}) => tasks.length > 0
    ? ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[400],
          ),
        ),
        itemCount: tasks.length,
      )
    : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              color: Colors.grey,
              size: 50,
            ),
            Text(
              'No tasks yet, Please add some tasks.',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      );
