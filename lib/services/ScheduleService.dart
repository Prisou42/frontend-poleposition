import 'dart:convert';

import 'package:http/http.dart' as http;

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
}