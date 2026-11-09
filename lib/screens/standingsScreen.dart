import 'package:flutter/material.dart';

import '../services/standingsService.dart';
import 'driverScreenStat.dart';

class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement drivers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: StandingsService.getStandings(),
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

          final drivers = snapshot.data ?? [];

          if (drivers.isEmpty) {
            return const Center(
              child: Text('Aucun pilote disponible'),
            );
          }

          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];

              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${driver['position']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (driver['image_url'] != null &&
                          driver['image_url'].toString().isNotEmpty)
                          ? Image.network(
                        'https://poleposition-api.onrender.com${driver['image_url']}',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person);
                        },
                      )
                          : const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.person, size: 35),
                      ),
                    ),
                  ],
                ),



                title: InkWell(
                  onTap: () {

                    debugPrint('ID du pilote : ${driver['id']}');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverCareerScreen(
                          driverId: (driver['id'] as num).toInt(),
                        ),
                      ),
                    );

                  },
                  child: Text(
                    '${driver['first_name']} ${driver['last_name']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                subtitle: Text(
                  '${driver['constructor_name'] ?? 'Écurie inconnue'}',
                ),

                trailing: Text(
                  '${driver['points']} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );;
            },
          );
        },
      ),
    );
  }
}