import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/user.dart';

class HiveDataStore {
  static const tasksBoxName = "tasksBox";
  static const usersBoxName = "usersBox";
  late Box<Task> tasksBox;
  late Box<User> usersBox;
  String? _currentUserId;

  // Singleton pattern
  static final HiveDataStore _instance = HiveDataStore._internal();
  factory HiveDataStore() => _instance;
  HiveDataStore._internal();

  // Initialize Hive, register adapters, and open boxes
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
      Hive.registerAdapter(UserAdapter());
    }
    tasksBox = await Hive.openBox<Task>(tasksBoxName);
    usersBox = await Hive.openBox<User>(usersBoxName);
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  String _generateUserId() {
    return const Uuid().v4();
  }

  Future<bool> signUp({required String email, required String password}) async {
    if (usersBox.values.any((user) => user.email == email)) {
      return false;
    }
    final userId = _generateUserId();
    final user = User(
      id: userId,
      email: email,
      passwordHash: _hashPassword(password),
    );
    await usersBox.put(userId, user);
    _currentUserId = userId;
    return true;
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      final user = usersBox.values.firstWhere(
        (user) => user.email == email && user.passwordHash == _hashPassword(password),
      );
      _currentUserId = user.id;
      return true;
    } catch (e) {
      throw Exception('Invalid credentials');
    }
  }

  void signOut() {
    _currentUserId = null;
  }

  bool isSignedIn() {
    return _currentUserId != null;
  }

  String? getCurrentUserId() {
    return _currentUserId;
  }

  String _getTaskKey(String taskId) {
    if (_currentUserId == null) {
      throw Exception("No authenticated user found");
    }
    return "${_currentUserId}_$taskId";
  }

  Future<void> addTask({required Task task}) async {
    final key = _getTaskKey(task.id);
    await tasksBox.put(key, task);
  }

  Future<Task?> getTask({required String id}) async {
    final key = _getTaskKey(id);
    return tasksBox.get(key);
  }

  Future<void> updateTask({required Task task}) async {
    final key = _getTaskKey(task.id);
    await tasksBox.put(key, task);
  }

  Future<void> deleteTask({required Task task}) async {
    final key = _getTaskKey(task.id);
    await tasksBox.delete(key);
  }

  Future<void> deleteAllTasks() async {
    if (_currentUserId == null) {
      throw Exception("No authenticated user found");
    }
    final keysToDelete = tasksBox.keys
        .where((key) => key.toString().startsWith(_currentUserId!))
        .toList();
    await tasksBox.deleteAll(keysToDelete);
  }

  List<Task> getUserTasks() {
    if (_currentUserId == null) {
      return [];
    }
    return tasksBox.values
        .where((task) => tasksBox.keyAt(tasksBox.values.toList().indexOf(task)).toString().startsWith(_currentUserId!))
        .toList();
  }

  ValueListenable<Box<Task>> listenToTask() {
    return tasksBox.listenable();
  }
}