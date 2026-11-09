import 'dart:convert';
import 'package:http/http.dart' as http;

class StandingsService {
  static Future<List<Map<String, dynamic>>> getStandings() async {
    final response = await http.get(
      Uri.parse('https://poleposition-api.onrender.com/drivers-standings'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((driver) => Map<String, dynamic>.from(driver))
          .toList();
    } else {
      throw Exception('Impossible de charger le classement');
    }
  }
}