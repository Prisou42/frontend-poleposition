import 'dart:convert';
import 'package:http/http.dart' as http;

class Standings1Service {
  static Future<List<Map<String, dynamic>>> get1Standings() async {
    final response = await http.get(
      Uri.parse('https://poleposition-api.onrender.com/constructors-standings'),
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