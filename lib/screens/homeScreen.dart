
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/services/authState.dart';

import '../models/news.dart';
import '../rows/newsRow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<News> films = [];

  bool isLoading = true;
  bool isLoggingOut = false;
  String? errorMessage;

  Future<void> _initFilms() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await News.fetchNews();

      if (!mounted) return;

      setState(() {
        films = response;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });

      debugPrint('NEWS ERROR: $error');
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

  void openSection(String title) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionPlaceholder(title: title),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 10),
                Text(
                  'PolePosition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toute la Formule 1',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Actualités'),
            onTap: () => Navigator.pop(context),
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'CHAMPIONNATS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

    ListTile(
    leading: const Icon(Icons.groups),
    title: const Text('Classement pilotes'),
    onTap: () {
    Navigator.pop(context);
    context.go('/drivers-standings');
    },
    ),

    ListTile(
    leading: const Icon(Icons.groups),
    title: const Text('Classement constructeurs'),
    onTap: () {
    Navigator.pop(context);
    context.go('/constructors-standings');
    },
    ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'FORMULE 1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendrier '),
              onTap: () {
                Navigator.pop(context);
                context.go('/races');
              }          ),

          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Résultats des courses'),
            onTap: () => openSection('Résultats des courses'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion'),
            onTap: isLoggingOut ? null : handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            const Text('Impossible de charger les actualités.'),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initFilms,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (films.isEmpty) {
      return const Center(
        child: Text('Aucune actualité disponible.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _initFilms,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: films.length,
        itemBuilder: (context, index) {
          return NewsRow(news: films[index]);
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        title: const Text('PolePosition'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _initFilms,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette rubrique doit encore être connectée aux données F1.',
            ),
          ],
        ),
      ),
    );
  }
}


