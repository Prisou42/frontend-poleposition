
import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  static const String baseUrl =
      'https://poleposition-api.onrender.com/news';

  final String title;
  final String? image;
  final String link;
  final String? description;

  News({
    required this.title,
    required this.link,
    this.image,
    this.description,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title']?.toString() ?? 'Sans titre',
      image: json['image']?.toString(),
      link: json['link']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  static Future<List<News>> fetchNews() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur ${response.statusCode} lors du chargement des actualités',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'La réponse API doit être une liste d actualités.',
      );
    }

    return decoded.map<News>((item) {
      return News.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}

