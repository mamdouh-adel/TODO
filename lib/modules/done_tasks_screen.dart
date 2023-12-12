import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

import '../shared/cubit/states.dart';

class DoneTasksScreen extends StatelessWidget {
  const DoneTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppCubit cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppState>(
      listener: (BuildContext context, AppState state) {},
      builder: (BuildContext context, AppState state) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            child: ListView.separated(
                itemBuilder: (context, index) =>
                    buildTaskItem(cubit.doneTasks[index], context),
                separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsetsDirectional.all(12.0),
                      child: Container(
                        height: 1.0,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                    ),
                itemCount: cubit.doneTasks.length),
          ),
        );
      },
    );
  }
}
