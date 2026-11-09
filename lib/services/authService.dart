import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled/config/APIConfig.dart';

class AuthService {

  static const String baseUrl = ApiConfig.baseUrl;

  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ?? 'Connexion impossible.',
      );
    }

    await _storage.write(
      key: 'access_token',
      value: data['accessToken'],
    );

    return Map<String, dynamic>.from(data['user']);
  }
  

  Future<void> logout() async {

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }
}