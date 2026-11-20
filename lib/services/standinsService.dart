
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/models/constructorStanding.dart';

import '../models/driverStanding.dart';

class StandingsService {
  static const String baseUrl =
      'https://poleposition-api.onrender.com';

  Future<List<DriverStanding>> getDriversStandings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/drivers-standings'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur classement pilotes : ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => DriverStanding.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  Future<List<ConstructorStanding>> getConstructorsStandings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/constructors-standings'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur classement constructeurs : ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => ConstructorStanding.fromJson(
      Map<String, dynamic>.from(item),
    ))
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
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
