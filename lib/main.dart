
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:untitled/models/drivers.dart';
import 'package:untitled/screens/driverScreenStat.dart';

import 'package:untitled/screens/loginScreen.dart';
import 'package:untitled/screens/registerScreen.dart';
import 'package:untitled/screens/homeScreen.dart';
import 'package:untitled/screens/scheduleScreen.dart';
import 'package:untitled/screens/scheduleScreenDetails.dart';
import 'package:untitled/screens/standings1Screen.dart';
import 'package:untitled/screens/standingsScreen.dart';
import 'package:untitled/screens/teamScreenStat.dart';
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
      path: '/races',
      builder: (context, state) => const RacesScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),



    GoRoute(
      path: '/drivers-standings',
      builder: (context, state) => const DriversStandingsScreen(),
    ),

    GoRoute(
      path: '/constructors-standings',
      builder: (context, state) => const ConstructorsStandingsScreen(),
    ),

    GoRoute(
      path: '/races/:season/:round',
      builder: (context, state) {
        final season = int.parse(
          state.pathParameters['season']!,
        );

        final round = int.parse(
          state.pathParameters['round']!,
        );

        return RaceDetailsScreen(
          season: season,
          round: round,
        );
      },
    ),





  ]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PolePosition',
      debugShowCheckedModeBanner: false,
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

class SectionPlaceholder extends StatelessWidget {
  final String title;

  const SectionPlaceholder({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title\nBientôt disponible',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}


