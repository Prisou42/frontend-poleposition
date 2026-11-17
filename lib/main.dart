
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:untitled/screens/loginScreen.dart';
import 'package:untitled/screens/registerScreen.dart';
import 'package:untitled/screens/homeScreen.dart';
import 'package:untitled/services/authState.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tzdata.initializeTimeZones();

  await authState.initialize();

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: authState,

  redirect: (context, state) {
    final loggedIn = authState.isAuthenticated;

    final loggingIn = state.matchedLocation == '/login';
    final registering = state.matchedLocation == '/register';

    if (!loggedIn && !loggingIn && !registering) {
      return '/login';
    }

    if (loggedIn && (loggingIn || registering)) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',

      builder: (context, state) => const RegisterScreen(),
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
