import 'package:flutter/material.dart';

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

Widget buildTaskItem(Map model) {
  return SingleChildScrollView(
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text("${model['time']}"),
        ),
        const SizedBox(width: 15,),
        Column(
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
        )
      ],
    ),
  );
}
