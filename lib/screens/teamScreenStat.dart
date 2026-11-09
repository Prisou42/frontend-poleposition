
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/config/APIConfig.dart';

class TeamCareerScreen extends StatefulWidget {
  final int teamId;

  const TeamCareerScreen( {
    super.key,
    required this.teamId,
  });

  @override
  State<TeamCareerScreen> createState() =>
      _TeamCareerScreenState();
}

class _TeamCareerScreenState
    extends State<TeamCareerScreen> {
  Map<String, dynamic>? team;
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
        '$baseUrl/teams/${widget.teamId}/historic-stats';

    debugPrint('URL appelée : $url');

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('STATUS STATS : ${response.statusCode}');
      debugPrint('BODY STATS : ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          team = Map<String, dynamic>.from(data);
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
        title: const Text('HISTORIQUE DU TEAM'),
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
                  if ((team!['imageurl'] ??
                      '').toString().isNotEmpty)
                    Image.network(
                      team!['imageurl'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) =>
                      const Icon(
                        Icons.person,
                        size: 100,
                      ),
                    ),
                  const SizedBox(height: 12),


                  Text(
                    '${team!['name']} '
                        ,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
            /* const SizedBox(height: 24), */
            const Text(
              'BILAN HISTORIQUE',
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
                  team!['total_races'],
                ),
                statCard(
                  'Victoires',
                  team!['wins'],
                ),
                statCard(
                  'Podiums',
                  team!['podiums'],
                ),
                statCard(
                  'Pole positions',
                  team!['poles'],
                ),
                statCard(
                  'Meilleurs tours',
                  team!['fastest_laps'],
                ),
                statCard(
                  'Points',
                  team!['points'],
                ),
                statCard(
                  'Titres pilotes',
                  team!['championshipsd'],
                ),
                statCard(
                  'Titres constructeurs',
                  team!['championshipsc'],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
