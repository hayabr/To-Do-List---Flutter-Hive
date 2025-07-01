import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/hive_data_store.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final DateTime createdAtTime;

  @HiveField(4)
  final DateTime createdAtDate;

  @HiveField(5)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtTime,
    required this.createdAtDate,
    this.isCompleted = false,
  });

  static Task create({
    required String title,
    required String subtitle,
    DateTime? createdAtTime,
    DateTime? createdAtDate,
  }) {
    final hiveDataStore = HiveDataStore();
    final userId = hiveDataStore.getCurrentUserId() ?? 'guest';
    final taskId = const Uuid().v4();
    return Task(
      id: "${userId}_$taskId",
      title: title,
      subtitle: subtitle,
      createdAtTime: createdAtTime ?? DateTime.now(),
      createdAtDate: createdAtDate ?? DateTime.now(),
    );
  }
}