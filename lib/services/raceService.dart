
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled/models/races.dart';

import '../models/races.dart';

class RacesService {
  static const String baseUrl =
      'https://poleposition-api.onrender.com';

  Future<List<Race>> getRaces() async {
    final response = await http
        .get(Uri.parse('$baseUrl/races'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur calendrier : ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    final races = data.map((item) {
      return Race.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();

    races.sort((a, b) => a.round.compareTo(b.round));

    return races;
  }

  static String imageUrl(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }
}
