
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/services/authState.dart';

import '../models/news.dart';
import '../rows/newsRow.dart';
import '../services/authService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var message = "Loading…";
  final films = <News>[];

  bool isLoggingOut = false;

  Future<void> _initFilms() async {
    try {
      final response = await News.fetchNews();

      if (!mounted) return;

      setState(() {
        if (response.isEmpty) {
          message = "No news found";
        } else {
          films.addAll(response);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => message = error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _initFilms();
  }

  Future<void> handleLogout() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    try {
      await authState.logout();
      if (!mounted) return;

      context.go('/login');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de déconnexion : $error'),
        ),
      );

      setState(() => isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolePosition'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: isLoggingOut
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout),
            onPressed: isLoggingOut ? null : handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: films.isEmpty
            ? Center(child: Text(message))
            : ListView.separated(
          itemCount: films.length,
          itemBuilder: (context, index) =>
              NewsRow(news: films[index]),
          separatorBuilder: (context, index) =>
          const Divider(),
        ),
      ),
    );
  }
}
