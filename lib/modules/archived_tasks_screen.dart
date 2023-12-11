import 'package:flutter/material.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Archived Tasks",
        style: TextStyle(
          fontSize: 50.0
        ),
      ),
    );
  }
}
