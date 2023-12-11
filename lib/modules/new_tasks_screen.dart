import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';

class NewTasksScreen extends StatelessWidget {
  NewTasksScreen({super.key}) {
    if (tasks.isEmpty) {
      Map dummyRecord = {
        "id": 0,
        "title": "First Task",
        "time": "00:00 AM",
        "date": DateFormat.yMMMd().format(DateTime.now())
      };

      tasks.add(dummyRecord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 20.0),
        child: ListView.separated(
            itemBuilder: (context, index) => buildTaskItem(tasks[index]),
            separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsetsDirectional.all(12.0),
                  child: Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
            itemCount: tasks.length),
      ),
    );
  }
}
