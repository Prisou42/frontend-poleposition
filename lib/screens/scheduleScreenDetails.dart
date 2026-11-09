
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:untitled/config/APIConfig.dart';

class ScheduleStatScreen extends StatefulWidget {
  final int round;
  final int season;
  final int raceId;

  const ScheduleStatScreen({
    super.key,
    required this.round,
    required this.season,
    required this.raceId,
  });

  @override
  State<ScheduleStatScreen> createState() =>
      _ScheduleStatScreenState();
}

class _ScheduleStatScreenState
    extends State<ScheduleStatScreen> {

  List<Map<String, dynamic>> drivers = [];

  Map<String, dynamic>? race;

  bool isLoading = true;
  String? error;
  String? resultsError;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchScheduleStats();
  }

  // RECUPERATION DES DONNEES
  Future<void> fetchScheduleStats() async {
    setState(() {
      isLoading = true;
      error = null;
      resultsError = null;
    });

    try {
      // 1. RECUPERATION DU PROGRAMME DU GP
      final raceUrl = Uri.parse(
        '$baseUrl/races/${widget.season}/${widget.round}',
      );

      final raceResponse = await http.get(raceUrl);

      if (raceResponse.statusCode != 200) {
        throw Exception(
          'Erreur horaires GP: ${raceResponse.statusCode}',
        );
      }

      final raceData = jsonDecode(raceResponse.body);

      Map<String, dynamic> raceMap;

      if (raceData is List) {
        if (raceData.isEmpty) {
          throw Exception('Course introuvable');
        }
        raceMap = Map<String, dynamic>.from(raceData.first);
      } else {
        raceMap = Map<String, dynamic>.from(raceData);
      }

      // 2. RECUPERATION DES RESULTATS
      List<Map<String, dynamic>> loadedDrivers = [];
      String? loadedResultsError;

      try {
        final resultsUrl = Uri.parse(
          '$baseUrl/races/${widget.season}/${widget.round}/results',
        );

        final response = await http.get(resultsUrl);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['results'] != null) {
            loadedDrivers =
            List<Map<String, dynamic>>.from(
              data['results'],
            );
          } else {
            loadedResultsError =
            'Aucun résultat disponible.';
          }
        } else {
          loadedResultsError =
          'Résultats indisponibles (${response.statusCode})';
        }
      } catch (e) {
        loadedResultsError = e.toString();
      }

      if (!mounted) return;

      setState(() {
        race = raceMap;
        drivers = loadedDrivers;
        resultsError = loadedResultsError;
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // CONVERSION DES DATES UTC EN HEURE LOCALE
  DateTime? parseSessionDate(dynamic date, dynamic time) {
    if (date == null || time == null) return null;

    try {
      final dateString = date.toString().substring(0, 10);
      final timeString = time.toString();

      final hasTimezone = RegExp(
        r'(Z|[+-]\d{2}:\d{2})$',
        caseSensitive: false,
      ).hasMatch(timeString);

      final dateTimeString = hasTimezone
          ? '${dateString}T$timeString'
          : '${dateString}T${timeString}Z';

      return DateTime.parse(dateTimeString).toUtc();
    } catch (_) {
      return null;
    }
  }

  // VERIFICATION SI LE GP EST A VENIR
  bool isRaceUpcoming() {
    if (race == null) return false;

    final raceDate = parseSessionDate(
      race!['race_date'],
      race!['race_time'],
    );

    if (raceDate == null) return false;

    return raceDate.isAfter(DateTime.now());
  }

  // PROGRAMME HORAIRE
  Widget buildSchedule() {

    final sessions = [
      {
        'name': 'FP1',
        'date': race!['fp1_date'],
        'time': race!['fp1_time'],
      },
      {
        'name': 'FP2',
        'date': race!['fp2_date'],
        'time': race!['fp2_time'],
      },
      {
        'name': 'FP3',
        'date': race!['fp3_date'],
        'time': race!['fp3_time'],
      },
      {
        'name': 'Qualifications',
        'date': race!['qualifying_date'],
        'time': race!['qualifying_time'],
      },
      {
        'name': 'Sprint Qualifying',
        'date': race!['sprint_qualifying_date'],
        'time': race!['sprint_qualifying_time'],
      },
      {
        'name': 'Sprint',
        'date': race!['sprint_date'],
        'time': race!['sprint_time'],
      },
      {
        'name': 'Course',
        'date': race!['race_date'],
        'time': race!['race_time'],
      },
    ];

    final availableSessions = sessions.where((session) {
      return session['date'] != null &&
          session['time'] != null;
    }).toList();

    if (availableSessions.isEmpty) {
      return const Text(
        'Programme horaire indisponible.',
      );
    }

    return Column(
      children: availableSessions.map((session) {

        final dateTime = parseSessionDate(
          session['date'],
          session['time'],
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 10),

          child: ListTile(
            leading: const Icon(
              Icons.schedule,
              size: 28,
            ),

            title: Text(
              session['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

              subtitle: dateTime == null
                  ? const Text('Horaire indisponible')
                  : buildSessionTime(dateTime),
          ),
        );

      }).toList(),
    );
  }

  // CARTE DE STATISTIQUE
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

  // RESULTATS DE LA COURSE
  Widget buildResults() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'RÉSULTATS DE LA COURSE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        if (drivers.isEmpty)
          Text(
            resultsError ?? 'Aucun résultat disponible.',
            style: const TextStyle(
              color: Colors.grey,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: drivers.length,

            itemBuilder: (context, index) {

              final driver = drivers[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Row(
                    children: [

                      // POSITION
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${driver['position'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // DRAPEAU
                    // DRAPEAU
                    if ((driver['flag'] ?? '').toString().trim().isNotEmpty)
              Image.network(
                getImageUrl(driver['flag']),
                width: 40,
                height: 27,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('ERREUR DRAPEAU : $error');
                  return const Icon(Icons.flag, size: 30);
                },
              )
              else
              const Icon(Icons.flag, size: 30),

                      const SizedBox(width: 12),

                      // NOM DU PILOTE
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              '${driver['first_name']} '
                                  '${driver['last_name']}',

                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                          ],
                        ),
                      ),

                      // ECART / STATUT
                      Text(
                        '${driver['gap'] ?? driver['status'] ?? '-'}',

                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
      ],
    );
  }

  // INTERFACE PRINCIPALE
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'CLASSEMENT DU GRAND PRIX',
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : error != null
          ? Center(
        child: Text(error!),
      )

          : race == null
          ? const Center(
        child: Text('Course introuvable'),
      )

          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            if (isRaceUpcoming()) ...[

              const Text(
                'PROGRAMME DU GRAND PRIX',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              buildSchedule(),

            ] else ...[

              buildResults(),

            ],
          ],
        ),
      ),
    );
  }
  Widget buildSessionTime(DateTime utcDate) {

    // Heure du téléphone
    final phoneTime = utcDate.toLocal();

    // Heure locale du circuit
    // À remplacer par le vrai fuseau du circuit.
    final circuitTime = phoneTime;

    final phoneFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          '📱 Mon heure : ${phoneFormat.format(phoneTime)}',
        ),

        Text(
          '🏁 Heure locale : ${phoneFormat.format(circuitTime)}',
        ),

        Text(
          dateFormat.format(phoneTime),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
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
