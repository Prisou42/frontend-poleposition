import 'package:flutter/material.dart';

import '../models/news.dart';
import '../rows/newsRow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var message = "Loading…";
  final films = <News>[];

  Future<void> _initFilms() async {
    try {
      var response = await News.fetchNews();
      setState(() {
        if (response.isEmpty) message = "No films found";
        films.addAll(response);
      });
    } catch (error) {
      setState(() => message = error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _initFilms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Tutoriel 5"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: films.isEmpty
            ? Column(children: [Center(child: Text(message))])
            : ListView.separated(
          itemCount: films.length,
          itemBuilder: (context, index) => NewsRow(news: films[index]),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }
}


