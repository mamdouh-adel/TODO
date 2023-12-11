import 'package:flutter/material.dart';

class DoneTasksScreen extends StatelessWidget {
  const DoneTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Done Tasks",
        style: TextStyle(
          fontSize: 50.0
        ),
      ),
    );
  }
}
