
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/news.dart';

class RssService {
  static const String apiUrl =
      'https://poleposition-api.onrender.com/news';

  Future<List<News>> getArticles([String? url]) async {
    try {
      final response = await http.get(
        Uri.parse(url ?? apiUrl),
      );

      debugPrint('NEWS STATUS: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur API : ${response.statusCode} - ${response.body}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'L’API doit renvoyer une liste JSON.',
        );
      }

      return decoded.map<News>((item) {
        return News.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

    } catch (error) {
      debugPrint('RSS ERROR: $error');
      rethrow;
    }
  }
}
