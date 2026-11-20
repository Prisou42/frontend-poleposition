
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/config/APIConfig.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ----------------------------------
  // IDENTIFIANT DE L'APPAREIL
  // ----------------------------------

  Future<String> _getDeviceId() async {
    String? deviceId =
    await _storage.read(key: 'device_id');

    if (deviceId != null) {
      return deviceId;
    }

    final random = Random.secure();

    deviceId = List.generate(
      32,
          (_) => random.nextInt(16).toRadixString(16),
    ).join();

    await _storage.write(
      key: 'device_id',
      value: deviceId,
    );

    return deviceId;
  }

  String _getDeviceType() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';

    throw Exception(
      'Plateforme non prise en charge.',
    );
  }

  String _getDeviceName() {
    if (Platform.isAndroid) return 'Android device';
    if (Platform.isIOS) return 'Apple device';

    return 'Unknown device';
  }

  // ----------------------------------
  // CONNEXION
  // ----------------------------------

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    final deviceId = await _getDeviceId();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'device_id': deviceId,
        'device_name': _getDeviceName(),
        'device_type': _getDeviceType(),
      }),
    );

    final responseData = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(
        responseData['message'] ??
            'Connexion impossible.',
      );
    }

    final data =
    Map<String, dynamic>.from(responseData['data']);

    await _saveTokens(data);

    return Map<String, dynamic>.from(data['user']);
  }

  // ----------------------------------
  // STOCKAGE DES TOKENS
  // ----------------------------------

  Future<void> _saveTokens(
      Map<String, dynamic> data,
      ) async {
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];

    if (accessToken is! String ||
        refreshToken is! String) {
      throw Exception(
        'Les tokens sont absents de la réponse API.',
      );
    }

    await _storage.write(
      key: 'access_token',
      value: accessToken,
    );

    await _storage.write(
      key: 'refresh_token',
      value: refreshToken,
    );;
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  // ----------------------------------
  // RENOUVELLEMENT DU JWT
  // ----------------------------------

  Future<bool> refreshToken() async {
    final refreshToken =
    await _storage.read(key: 'refresh_token');

    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      final responseData = _decodeResponse(response);

      if (response.statusCode != 200) {
        await logoutLocal();
        return false;
      }

      final data =
      Map<String, dynamic>.from(responseData['data']);

      await _saveTokens(data);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ----------------------------------
  // PROFIL UTILISATEUR
  // ----------------------------------

  Future<Map<String, dynamic>> getMe() async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception('Utilisateur non connecté.');
    }

    var response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      final refreshed = await refreshToken();

      if (!refreshed) {
        throw Exception('Session expirée.');
      }

      accessToken = await getAccessToken();

      response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
    }

    final responseData = _decodeResponse(response);

    if (response.statusCode != 200) {
      throw Exception(
        responseData['message'] ??
            'Impossible de récupérer le profil.',
      );
    }

    return Map<String, dynamic>.from(
      responseData['data'],
    );
  }

  // ----------------------------------
  // DECONNEXION SERVEUR
  // ----------------------------------


  Future<void> logout() async {
    final accessToken = await getAccessToken();

    try {
      if (accessToken != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Erreur serveur lors de la déconnexion : ${response.statusCode}',
          );
        }
      }
    } finally {
      await logoutLocal();
    }
  }




  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required bool acceptTerms,
  }) async {
    final deviceId = await _getDeviceId();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'accept_terms': acceptTerms,
        'device_id': deviceId,
        'device_name': _getDeviceName(),
        'device_type': _getDeviceType(),
      }),
    );

    print('REGISTER STATUS: ${response.statusCode}');
    print('REGISTER BODY: ${response.body}');

    final responseData = _decodeResponse(response);

    if (response.statusCode != 201) {
      throw Exception(
        responseData['message'] ?? 'Inscription impossible.',
      );
    }

    final data = Map<String, dynamic>.from(responseData['data']);

    await _saveTokens(data);

    return Map<String, dynamic>.from(data['user']);
  }



  // ----------------------------------
  // SUPPRESSION LOCALE DES TOKENS
  // ----------------------------------

  Future<void> logoutLocal() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> testNews() async {
    try {
      final uri = Uri.parse('$baseUrl/news');

      print('NEWS URL: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      print('NEWS STATUS: ${response.statusCode}');
      print('NEWS BODY: ${response.body}');
    } catch (e, stackTrace) {
      print('NEWS ERROR: $e');
      print(stackTrace);
    }
  }

  // ----------------------------------
  // DECODAGE DES REPONSES
  // ----------------------------------

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Réponse non JSON
    }

    throw Exception(
      'Réponse invalide du serveur (${response.statusCode}).',
    );
  }
}
