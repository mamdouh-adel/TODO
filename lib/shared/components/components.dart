import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

Widget defaultFormField(
    {required TextEditingController controller,
    required TextInputType inputType,
    required String label,
    required String? Function(String?) validate,
    IconData? prefix,
    IconData? suffix,
    Function(String?)? onSubmit,
    Function(String?)? onChanged,
    Function()? onTap}) {
  return TextFormField(
    controller: controller,
    keyboardType: inputType,
    decoration: InputDecoration(
        labelText: label,
        prefix: prefix == null ? null : Icon(prefix),
        suffix: suffix == null ? null : Icon(suffix)),
    validator: validate,
    onFieldSubmitted: onSubmit,
    onChanged: onChanged,
    onTap: onTap,
  );
}

Widget buildTaskItem(Map model, BuildContext context) {
  AppCubit cubit = AppCubit.get(context);
  return BlocConsumer<AppCubit, AppState>(
    listener: (BuildContext context, AppState state) {},
    builder: (BuildContext context, AppState state) {
      return Dismissible(
        key: Key(model["id"].toString()),
        onDismissed: (DismissDirection dir) {
          if (dir == DismissDirection.startToEnd) {
            cubit.deleteData(model["id"]);
          }
        },
        child: SingleChildScrollView(
          child: Row(
            children: [
              CircleAvatar(
                radius: 40.0,
                child: Text("${model['time']}"),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${model['title']}",
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${model['date']}",
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  cubit.updateData("done", model['id']);
                },
                icon: const Icon(Icons.check_circle),
                color: Colors.green,
              ),
              const SizedBox(
                width: 15,
              ),
              IconButton(
                onPressed: () {
                  cubit.updateData("archived", model['id']);
                },
                icon: const Icon(Icons.archive),
                color: Colors.black38,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildTasks(List<Map> tasks) => BlocConsumer<AppCubit, AppState>(
      listener: (BuildContext context, AppState state) {},
      builder: (BuildContext context, AppState state) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 20.0),
            child: ConditionalBuilder(
              condition: tasks.isNotEmpty,
              builder: (context) => ListView.separated(
                  itemBuilder: (context, index) =>
                      buildTaskItem(tasks[index], context),
                  separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsetsDirectional.all(12.0),
                        child: Container(
                          height: 1.0,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ),
                  itemCount: tasks.length),
              fallback: (context) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.ac_unit,
                      color: Colors.black12,
                      size: 88,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No Tasks",
                      style: TextStyle(
                          color: Colors.black12,
                          fontWeight: FontWeight.bold,
                          fontSize: 24),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
