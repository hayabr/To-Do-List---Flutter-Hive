import 'package:flutter/material.dart';
import 'package:todoohive/data/hive_data_store.dart';
import 'package:todoohive/view/auth/sign_in_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize HiveDataStore singleton
  await HiveDataStore().init();
  runApp(BaseWidget(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDooHive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInView(),
    );
  }
}

class BaseWidget extends InheritedWidget {
  final HiveDataStore dataStore = HiveDataStore();

  BaseWidget({required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static BaseWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BaseWidget>()!;
  }
}