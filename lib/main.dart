
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled/screens/loginScreen.dart';
import 'package:untitled/screens/newsScreen.dart';
import 'package:timezone/data/latest.dart' as tzdata;


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  tzdata.initializeTimeZones();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
   initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>  HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PolePosition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolePosition'),
      ),
      body:  Center(
        child: SizedBox(
          width: 500,
          child: NewsScreen(),
        ),
      ),
    );
  }
}
