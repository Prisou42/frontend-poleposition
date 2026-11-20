
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/raceDetails.dart';

class RaceDetailsService {
  static const String baseUrl =
      'https://poleposition-api.onrender.com';

  Future<RaceDetails> getRaceDetails(
      int season,
      int round,
      ) async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/races/$season/$round'),
    )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur détails du Grand Prix : ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    return RaceDetails.fromJson(data);
  }
}
