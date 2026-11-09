
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_avif/flutter_avif.dart';
import 'package:untitled/config/APIConfig.dart';

class DriverCareerScreen extends StatefulWidget {
  final int driverId;

  const DriverCareerScreen( {
    super.key,
    required this.driverId,
  });

  @override
  State<DriverCareerScreen> createState() =>
      _DriverCareerScreenState();
}

class _DriverCareerScreenState
    extends State<DriverCareerScreen> {
  Map<String, dynamic>? driver;
  bool isLoading = true;
  String? error;

  // Adresse de ton backend Node.js
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchCareerStats();
  }

  Future<void> fetchCareerStats() async {
    final url =
        '$baseUrl/drivers/${widget.driverId}/career-stats';

    debugPrint('URL appelée : $url');

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('STATUS STATS : ${response.statusCode}');
      debugPrint('BODY STATS : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          driver = Map<String, dynamic>.from(data);
          isLoading = false;
          error = null;
        });
      } else {
        if (!mounted) return;

        setState(() {
          error =
          'Erreur HTTP ${response.statusCode} : ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ERREUR STATS : $e');

      if (!mounted) return;

      setState(() {
        error = 'Erreur : $e';
        isLoading = false;
      });
    }
  }


  Widget statCard(String title, dynamic value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value?.toString() ?? '0',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STATISTIQUES DE CARRIÈRE'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : error != null
          ? Center(
        child: Text(error!),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  if ((driver!['image_url'] ??
                      '').toString().isNotEmpty)
        if ((driver!['image_url'] ?? '').toString().isNotEmpty)
    Image.network(
    getImageUrl(driver!['image_url']),
    width: 150,
    height: 150,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
    debugPrint('ERREUR IMAGE : $error');

    return const Icon(
    Icons.person,
    size: 100,
    );
    },
    ),
                  const SizedBox(height: 12),
                  Text(
                    '${driver!['first_name']} '
                        '${driver!['last_name']}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    driver!['nationality'] ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'BILAN DE CARRIÈRE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                statCard(
                  'Grands Prix',
                  driver!['total_races'],
                ),
                statCard(
                  'Victoires',
                  driver!['wins'],
                ),
                statCard(
                  'Podiums',
                  driver!['podiums'],
                ),
                statCard(
                  'Pole positions',
                  driver!['poles'],
                ),
                statCard(
                  'Meilleurs tours',
                  driver!['fastest_laps'],
                ),
                statCard(
                  'Points',
                  driver!['points'],
                ),
                statCard(
                  'Titres mondiaux',
                  driver!['championships'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String getImageUrl(dynamic imagePath) {
    if (imagePath == null || imagePath.toString().trim().isEmpty) {
      return '';
    }

    final path = imagePath.toString().trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '$baseUrl/${path.startsWith('/') ? path.substring(1) : path}';
  }
}

