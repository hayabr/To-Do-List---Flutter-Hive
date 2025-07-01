import 'package:flutter/material.dart';
import 'package:todoohive/data/hive_data_store.dart';
import 'package:todoohive/models/task.dart';


class TaskWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit; // Callback for edit action

  const TaskWidget({Key? key, required this.task, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(task.title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(task.subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  subtitle: task.subtitle,
                  createdAtTime: task.createdAtTime,
                  createdAtDate: task.createdAtDate,
                  isCompleted: value ?? false,
                );
                HiveDataStore().updateTask(task: updatedTask);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit, // Trigger edit callback
            ),
          ],
        ),
        onTap: onEdit, // Optional: Tap entire tile to edit
      ),
    );
  }
}