import 'package:flutter/material.dart';
import '../../data/hive_data_store.dart';
import '../home/home_view.dart';
import 'sign_in_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveDataStore = HiveDataStore();
    return hiveDataStore.isSignedIn() ? const HomeView() : const SignInView();
  }
}