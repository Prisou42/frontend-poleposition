

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class News {
  static const baseUrl = "https://localhost:3000/news";


  final int id;
  final String title;
  final String? image;
  final String link;
  final String? description;





  News({required this.id, required this.title, required this.link, required this.image, this.description});





  static Future<List<News>> fetchNews() async {
    var response = await http.get(Uri.parse("$baseUrl/"));

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode} fetching news");
    }

    return compute((input) {
      final jsonList = jsonDecode(input);
      return jsonList.map<News>((jsonObj) => News(
        id: jsonObj["id"],
        title: jsonObj["title"],
        image: jsonObj["director"],
        link: jsonObj["link"],
        description: jsonObj["description"],

      )).toList();
    }, response.body);
  }
}

