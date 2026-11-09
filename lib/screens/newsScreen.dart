
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled/screens/scheduleScreen.dart';
import 'package:untitled/screens/standings1Screen.dart';
import 'package:untitled/screens/standingsScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news.dart';
import '../services/rssService.dart';

class NewsScreen extends StatelessWidget {
  NewsScreen({super.key});

  final RssService rss = RssService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Mon profil'),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 35),
              ), accountEmail: null,
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Connexion'),
              onTap: () {
                context.go("/login");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Inscription'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes favoris'),
              onTap: () {
                context.go("/");
                Navigator.pop(context);
                // Ajouter ici la navigation vers les favoris
              },
            ),
          ],
        ),
      ),

      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'PolePosition',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

    ListTile(
    leading: const Icon(Icons.emoji_events),
    title: const Text('Classement pilotes'),
    onTap: () {
    Navigator.pop(context);

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => const StandingsScreen(),
    ),
    );
    },
    ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Classement constructeurs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Standings1Screen(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendrier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduleScreen(),
                    ));
              },
            ),
          ],
        ),
      ),

      // BARRE DE NAVIGATION
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Mon profil',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Pole Position'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu principal',
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // TON FLUX RSS EXISTANT
      body: FutureBuilder<List<News>>(
        future: rss.getArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          final articles = snapshot.data ?? [];

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final news = articles[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news.image != null)
                    Image.network(
                      news.image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox();
                      },
                    ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () async {
                        final uri = Uri.tryParse(news.link);

                        if (uri != null &&
                            (uri.scheme == 'https' ||
                                uri.scheme == 'http')) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
