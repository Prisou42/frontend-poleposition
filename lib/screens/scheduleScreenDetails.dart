
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/raceDetails.dart';
import '../services/raceDetailsService.dart';
import '../widgets/polePositionAppBar.dart';

class RaceDetailsScreen extends StatefulWidget {
  final int season;
  final int round;

  const RaceDetailsScreen({
    super.key,
    required this.season,
    required this.round,
  });

  @override
  State<RaceDetailsScreen> createState() =>
      _RaceDetailsScreenState();
}

class _RaceDetailsScreenState extends State<RaceDetailsScreen> {
  final RaceDetailsService service = RaceDetailsService();

  RaceDetails? race;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadRace();
  }

  Future<void> loadRace() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await service.getRaceDetails(
        widget.season,
        widget.round,
      );

      if (!mounted) return;

      setState(() {
        race = result;
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

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatTime(String? dateValue, String? timeValue) {
    if (dateValue == null ||
        timeValue == null ||
        dateValue.isEmpty ||
        timeValue.isEmpty) {
      return 'Non programmée';
    }

    try {
      final date = DateTime.parse(dateValue).toUtc();

      final parts = timeValue.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final location = tz.getLocation(
        race!.circuitTimezone,
      );

      final circuitTime = tz.TZDateTime(
        location,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      final belgiumTime = circuitTime.toLocal();

      return 'Circuit : ${formatDate(circuitTime)} à '
          '${circuitTime.hour.toString().padLeft(2, '0')}:'
          '${circuitTime.minute.toString().padLeft(2, '0')}\n'
          'Belgique : ${formatDate(belgiumTime)} à '
          '${belgiumTime.hour.toString().padLeft(2, '0')}:'
          '${belgiumTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '$dateValue • $timeValue';
    }
  }

  Widget buildSession(
      String title,
      String? date,
      String? time, {
        bool highlight = false,
      }) {
    if (date == null ||
        time == null ||
        date.isEmpty ||
        time.isEmpty ||
        date == 'null' ||
        time == 'null') {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      child: ListTile(
        leading: Icon(
          highlight ? Icons.flag : Icons.timer,
          color: highlight ? Colors.red : null,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            formatTime(date, time),
            style: const TextStyle(height: 1.6),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    final currentRace = race!;

    return RefreshIndicator(
      onRefresh: loadRace,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GRAND PRIX N° ${currentRace.round}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentRace.raceName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Saison ${currentRace.season}'),
                const SizedBox(height: 5),
                Text(
                  'Fuseau horaire : ${currentRace.circuitTimezone}',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Text(
              'PROGRAMME DU WEEK-END',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          buildSession(
            'Essais libres 1',
            currentRace.fp1Date,
            currentRace.fp1Time,
          ),
          buildSession(
            'Essais libres 2',
            currentRace.fp2Date,
            currentRace.fp2Time,
          ),
          buildSession(
            'Essais libres 3',
            currentRace.fp3Date,
            currentRace.fp3Time,
          ),
          buildSession(
            'Qualifications sprint',
            currentRace.sprintQualifyingDate,
            currentRace.sprintQualifyingTime,
          ),
          buildSession(
            'Course sprint',
            currentRace.sprintDate,
            currentRace.sprintTime,
          ),
          buildSession(
            'Qualifications',
            currentRace.qualifyingDate,
            currentRace.qualifyingTime,
          ),
          buildSession(
            'COURSE',
            currentRace.raceDate,
            currentRace.raceTime,
            highlight: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PolePositionAppBar(
        title: 'Détails du Grand Prix',
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : error != null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loadRace,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : buildContent(),
    );
  }
}


