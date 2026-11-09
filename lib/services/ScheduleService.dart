import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/APIConfig.dart';

class ScheduleService {
  static Future<List<Map<String, dynamic>>> getSchedule() async {
    final response = await http.get(
      Uri.parse('https://poleposition-api.onrender.com/races'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((driver) => Map<String, dynamic>.from(driver))
          .toList();
    } else {
      throw Exception('Impossible de charger le calendrier');
    }
  }
  Future<Map<String, dynamic>> getRaceDetails(
      int season, int round) async {
     const String baseUrl = ApiConfig.baseUrl;


    final response = await http.get(
      Uri.parse('$baseUrl/races/$season/$round'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Impossible de récupérer le GP');
  }
}