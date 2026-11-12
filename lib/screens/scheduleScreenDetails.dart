
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
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
  List<Map<String, dynamic>> qualifyingDrivers = [];
  List<Map<String, dynamic>> loadedQualifying = [];
  String selectedResult = 'race';
  bool isLoadingQualifying = false;
  String? qualifyingError;


  List<Map<String, dynamic>> drivers = [];

  Map<String, dynamic>? race;

  bool isLoading = true;
  String? error;
  String? resultsError;

  final String baseUrl = ApiConfig.baseUrl;


  @override
  void initState() {
    super.initState();

    tzdata.initializeTimeZones();

    fetchScheduleStats();
  }

  // RECUPERATION DES DONNEES
  // RECUPERATION DES DONNEES
  Future<void> fetchScheduleStats() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = null;
      resultsError = null;
    });

    // Variables locales
    Map<String, dynamic>? loadedRace;
    List<Map<String, dynamic>> loadedDrivers = [];
    List<Map<String, dynamic>> loadedQualifying = [];


    String? loadedResultsError;

    try {
      // 1. RECUPERATION DU PROGRAMME DU GP
      final raceUrl = Uri.parse(
        '$baseUrl/races/${widget.season}/${widget.round}',
      );

      final raceResponse = await http.get(raceUrl);

      if (raceResponse.statusCode != 200) {
        throw Exception(
          'Erreur horaires GP : ${raceResponse.statusCode}',
        );
      }

      final raceData = jsonDecode(raceResponse.body);

      if (raceData is List) {
        if (raceData.isEmpty) {
          throw Exception('Course introuvable');
        }

        loadedRace = Map<String, dynamic>.from(
          raceData.first,
        );
      } else if (raceData is Map) {
        loadedRace = Map<String, dynamic>.from(raceData);
      } else {
        throw Exception('Format des données GP invalide');
      }

      // 2. RECUPERATION DES RESULTATS DE COURSE
      try {
        final resultsUrl = Uri.parse(
          '$baseUrl/races/${widget.season}/${widget.round}/results',
        );

        final response = await http.get(resultsUrl);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data is Map && data['results'] is List) {
            loadedDrivers =
            List<Map<String, dynamic>>.from(
              data['results'],
            );

            if (loadedDrivers.isEmpty) {
              loadedResultsError = 'Aucun résultat disponible.';
            }
          } else {
            loadedResultsError = 'Aucun résultat disponible.';
          }
        } else {
          loadedResultsError =
          'Résultats indisponibles (${response.statusCode})';
        }
      } catch (e) {
        loadedResultsError = e.toString();
      }



      // 4. MISE A JOUR DE L'ECRAN
      if (!mounted) return;

      setState(() {
        race = loadedRace;
        drivers = loadedDrivers;
        qualifyingDrivers = loadedQualifying;
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
      final circuitTimezone = race?['circuit_timezone']?.toString();

      if (circuitTimezone == null || circuitTimezone.isEmpty) {
        debugPrint('Fuseau horaire du circuit introuvable');
        return null;
      }

      final location = tz.getLocation(circuitTimezone);

      // La date ISO reçue du backend représente un instant UTC.
      // On récupère le jour correspondant dans le fuseau du circuit.
      final utcDate = DateTime.parse(date.toString()).toUtc();
      final circuitDate = tz.TZDateTime.from(utcDate, location);

      final timeString = time.toString();

      final parts = timeString.split(':');

      if (parts.length < 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final second = parts.length >= 3
          ? int.parse(parts[2].split('.').first)
          : 0;

      // Construction de l'heure locale du circuit.
      final sessionDate = tz.TZDateTime(
        location,
        circuitDate.year,
        circuitDate.month,
        circuitDate.day,
        hour,
        minute,
        second,
      );
      final isPast = sessionDate != null &&
          sessionDate.isBefore(DateTime.now().toUtc());

      // Retour en UTC pour les comparaisons.
      return sessionDate.toUtc();
    } catch (e) {
      debugPrint('Erreur parseSessionDate : $e');
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
    if (race == null) {
      return const Center(
        child: Text('Informations du Grand Prix indisponibles'),
      );
    }

    final sessions = [
      {
        'name': 'FP1',
        'date': race!['fp1_date'],
        'time': race!['fp1_time'],
        'duration': 60,
      },
      {
        'name': 'FP2',
        'date': race!['fp2_date'],
        'time': race!['fp2_time'],
        'duration': 60,
      },
      {
        'name': 'FP3',
        'date': race!['fp3_date'],
        'time': race!['fp3_time'],
        'duration': 60,
      },
      {
        'name': 'Qualifications',
        'date': race!['qualifying_date'],
        'time': race!['qualifying_time'],
        'duration': 60,
      },
      {
        'name': 'Sprint Qualifying',
        'date': race!['sprint_qualifying_date'],
        'time': race!['sprint_qualifying_time'],
        'duration': 60,
      },
      {
        'name': 'Sprint',
        'date': race!['sprint_date'],
        'time': race!['sprint_time'],
        'duration': 60,
      },
      {
        'name': 'Course',
        'date': race!['race_date'],
        'time': race!['race_time'],
        'duration': 120,
      },
    ];

    final validSessions = sessions.where((session) {
      return session['date'] != null &&
          session['time'] != null;
    }).toList();

    if (validSessions.isEmpty) {
      return const Center(
        child: Text('Aucune séance programmée'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Text(
            'PROGRAMME DU WEEK-END',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ...validSessions.map((session) {
          final sessionDate = parseSessionDate(
            session['date'],
            session['time'],
          );

          final status = getSessionStatus(
            sessionDate: sessionDate,
            hasResults: false,
            durationMinutes: session['duration'] as int,
          );

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

                leading: session['name'] == 'Qualifications'
                    ? loadedQualifying.isNotEmpty
                    ? Image.network(
                  loadedQualifying.first['flag']?.toString() ?? '',
                  width: 36,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.flag, size: 28);
                  },
                )
                    : const Icon(Icons.flag, size: 28)
                    : Icon(
                  session['name'] == 'Course'
                      ? Icons.flag
                      : Icons.sports_motorsports,
                  size: 28,
                ),

              title: Text(
                session['name'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSessionTime(
                      session['date'],
                      session['time'],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: getSessionStatusColor(status),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          status,
                          style: TextStyle(
                            color: getSessionStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
    final bool isRace = selectedResult == 'race';

    final displayedDrivers = isRace
        ? drivers
        : qualifyingDrivers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'RÉSULTATS DU GRAND PRIX',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // SÉLECTION DE LA SESSION
        DropdownButtonFormField<String>(
          value: selectedResult,
          decoration: const InputDecoration(
            labelText: 'Session',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'race',
              child: Text('Course'),
            ),
            DropdownMenuItem(
              value: 'Q1',
              child: Text('Qualifications Q1'),
            ),
            DropdownMenuItem(
              value: 'Q2',
              child: Text('Qualifications Q2'),
            ),
            DropdownMenuItem(
              value: 'Q3',
              child: Text('Qualifications Q3'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedResult = value;
            });

            if (value != 'race') {
              fetchQualifyingResults(value);
            }
          },
        ),

        const SizedBox(height: 20),

        // TITRE DU CLASSEMENT
        Text(
          isRace
              ? 'CLASSEMENT DE LA COURSE'
              : 'CLASSEMENT ${selectedResult.toUpperCase()}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // CHARGEMENT
        if (!isRace && isLoadingQualifying)
          const Center(
            child: CircularProgressIndicator(),
          )

        // ERREUR OU ABSENCE DE RÉSULTATS
        else if (displayedDrivers.isEmpty)
          Text(
            isRace
                ? resultsError ?? 'Aucun résultat disponible.'
                : qualifyingError ?? 'Aucun résultat disponible.',
            style: const TextStyle(
              color: Colors.grey,
            ),
          )

        // LISTE DES PILOTES
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedDrivers.length,

            itemBuilder: (context, index) {
              final driver = displayedDrivers[index];

              final position = isRace
                  ? driver['position'] ?? '-'
                  : driver['session_position'] ?? '-';

              final firstName = isRace
                  ? driver['first_name'] ?? ''
                  : driver['given_name'] ?? '';

              final lastName = isRace
                  ? driver['last_name'] ?? ''
                  : driver['family_name'] ?? '';

              final teamName = isRace
                  ? ''
                  : driver['constructor_name'] ?? '';

              final lapTime = isRace
                  ? null
                  : driver[selectedResult.toLowerCase()];


              return Card(
                margin: const EdgeInsets.only(bottom: 10),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Row(
                    children: [

                      // POSITION
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$position',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),


                      // DRAPEAU POUR LA COURSE
                    // DRAPEAU COURSE ET QUALIFICATIONS
                    if ((driver['flag'] ?? '').toString().trim().isNotEmpty)
              Image.network(
                getImageUrl(driver['flag']),
                width: 40,
                height: 27,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.flag, size: 30);
                },
              )
              else
              const Icon(Icons.flag, size: 30),

                      const SizedBox(width: 12),

                      // NOM ET ÉCURIE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              '$firstName $lastName',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (!isRace) ...[
                              const SizedBox(height: 4),
                              Text(
                                teamName.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // TEMPS OU ÉCART
                      Text(
                        isRace
                            ? '${driver['gap'] ?? driver['status'] ?? '-'}'
                            : '${lapTime ?? '-'}',
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
  Widget buildSessionTime(dynamic date, dynamic time) {
    final sessionUtc = parseSessionDate(date, time);

    if (sessionUtc == null) {
      return const Text('Horaire indisponible');
    }

    final phoneTime = sessionUtc.toLocal();

    final circuitTimezone = race?['circuit_timezone']?.toString();

    if (circuitTimezone == null || circuitTimezone.isEmpty) {
      return const Text('Fuseau horaire indisponible');
    }

    final location = tz.getLocation(circuitTimezone);
    final circuitTime = tz.TZDateTime.from(sessionUtc, location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Circuit : ${DateFormat('dd/MM/yyyy HH:mm').format(circuitTime)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Téléphone : ${DateFormat('dd/MM/yyyy HH:mm').format(phoneTime)}',
          style: const TextStyle(color: Colors.grey),
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
  String formatSessionTime(
      dynamic date,
      dynamic time,
      String circuitTimezone,
      ) {
    if (date == null || time == null) return '--:--';

    final dateString = DateTime.parse(date.toString())
        .toUtc()
        .toIso8601String()
        .substring(0, 10);

    final timeString = time.toString();

    final location = tz.getLocation(circuitTimezone);

    final circuitDateTime = tz.TZDateTime(
      location,
      int.parse(dateString.substring(0, 4)),
      int.parse(dateString.substring(5, 7)),
      int.parse(dateString.substring(8, 10)),
      int.parse(timeString.substring(0, 2)),
      int.parse(timeString.substring(3, 5)),
    );

    final phoneDateTime = circuitDateTime.toLocal();

    return 'Circuit : ${DateFormat('dd/MM HH:mm').format(circuitDateTime)}\n'
        'Ton téléphone : ${DateFormat('dd/MM HH:mm').format(phoneDateTime)}';
  }
  Color getSessionStatusColor(String status) {
    switch (status) {
      case 'Terminée':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'À venir':
        return Colors.blue;
      case 'Résultats en attente':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }
  String getSessionStatus({
    required DateTime? sessionDate,
    required bool hasResults,
    required int durationMinutes,
  }) {
    if (sessionDate == null) return 'Horaire indisponible';

    final now = DateTime.now().toUtc();
    final endDate = sessionDate.add(
      Duration(minutes: durationMinutes),
    );

    if (now.isBefore(sessionDate)) {
      return 'À venir';
    }

    if (now.isBefore(endDate)) {
      return 'En cours';
    }

    if (hasResults) {
      return 'Terminée';
    }

    return 'Résultats en attente';
  }
  Future<void> fetchQualifyingResults(String session) async {
    if (!mounted) return;

    setState(() {
      isLoadingQualifying = true;
      qualifyingError = null;
      qualifyingDrivers = [];
    });

    try {
      final url = Uri.parse(
        '$baseUrl/races/${widget.season}/${widget.round}/qualifying/$session',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur qualifications : ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data is Map && data['results'] is List) {
        final loadedDrivers =
        List<Map<String, dynamic>>.from(data['results']);

        if (!mounted) return;

        setState(() {
          qualifyingDrivers = loadedDrivers;

          if (loadedDrivers.isEmpty) {
            qualifyingError = 'Aucun résultat disponible pour $session.';
          }
        });
      } else {
        throw Exception('Format des qualifications invalide.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        qualifyingError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingQualifying = false;
        });
      }
    }
  }
}
