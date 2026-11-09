import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news.dart';

class NewsRow extends StatelessWidget {
  final News news;

  const NewsRow({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(news.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Directed by ${news.description} - ${news.title} "),
          InkWell(
            onTap: () => launchUrl(Uri.parse(news.title))
          )
        ],
      ),
    );
  }
}