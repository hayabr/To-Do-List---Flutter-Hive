import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todoohive/data/hive_data_store.dart';
import 'package:todoohive/models/task.dart';
import 'package:todoohive/utils/constanst.dart';
import 'package:uuid/uuid.dart';


class TaskView extends StatefulWidget {
  final TextEditingController? taskControllerForTitle;
  final TextEditingController? taskControllerForSubtitle;
  final Task? task;

  const TaskView({
    Key? key,
    this.taskControllerForTitle,
    this.taskControllerForSubtitle,
    this.task,
  }) : super(key: key);

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  final HiveDataStore _dataStore = HiveDataStore();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = widget.taskControllerForTitle ?? TextEditingController();
    _subtitleController = widget.taskControllerForSubtitle ?? TextEditingController();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _subtitleController.text = widget.task!.subtitle;
      _selectedDate = widget.task!.createdAtDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.createdAtTime);
    }
  }

  @override
  void dispose() {
    if (widget.taskControllerForTitle == null) _titleController.dispose();
    if (widget.taskControllerForSubtitle == null) _subtitleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final now = DateTime.now();
    final date = _selectedDate ?? now;
    final time = _selectedTime ?? TimeOfDay.fromDateTime(now);
    final createdAtTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      createdAtTime: createdAtTime,
      createdAtDate: date,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    try {
      if (widget.task == null) {
        _dataStore.addTask(task: task);
        print('Task added: ${task.title}');
      } else {
        _dataStore.updateTask(task: task);
        print('Task updated: ${task.title}');
      }
      Navigator.pop(context);
    } catch (e) {
      print('SaveTask error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                lottieURL,
                animate: true,
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Task Subtitle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.toString().split(' ')[0]}',
              ),
            ),
            TextButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}