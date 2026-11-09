import 'package:flutter/material.dart';
import 'package:untitled/screens/scheduleScreenDetails.dart';
import '../services/ScheduleService.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ScheduleService.getSchedule(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          final races = snapshot.data ?? [];

          if (races.isEmpty) {
            return const Center(
              child: Text('Aucune course disponible'),
            );
          }

          return ListView.builder(
            itemCount: races.length,
            itemBuilder: (context, index) {
              final race = races[index];

              final imagePath = race['circuit_image']?.toString().trim() ?? '';

              String? imageUrl;

              if (imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://')) {
                imageUrl = imagePath;
              } else if (imagePath.isNotEmpty) {
                imageUrl = 'https://poleposition-api.onrender.com/'
                    '${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
              }

              debugPrint('Image du circuit : $imageUrl');
              debugPrint('Image du circuit : $imageUrl');

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Erreur image : $error');

                        return const Icon(
                          Icons.flag,
                          size: 35,
                        );
                      },
                    )
                        : const Icon(
                      Icons.flag,
                      size: 35,
                    ),
                  ),
                ),
                title: InkWell(
                  onTap: () {
                    debugPrint('ID de la race : ${race['id']}');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleStatScreen(
                          raceId: (race['id'] as num).toInt(), round: race['round'], season: race['season'],
                        ),
                      ),
                    );

                    
                  },
                    child: Text(
                (race['race_name']?.toString() ?? 'Grand Prix').toUpperCase(),
              style: const TextStyle(
              fontWeight: FontWeight.bold,
              ))),

                    
                

                

                  subtitle: Text(() {
                    final date = race['race_date']?.toString();

                    if (date == null || date.isEmpty) {
                      return 'Date inconnue';
                    }

                    final parsedDate = DateTime.tryParse(date);

                    if (parsedDate == null) {
                      return date.split('T').first;
                    }

                    final day = parsedDate.day.toString().padLeft(2, '0');
                    final month = parsedDate.month.toString().padLeft(2, '0');

                    final year = parsedDate.year;

                    return '$day-$month-$year';
                  }()),
              );
            },
          );
        },
      ),
    );
  }
}
