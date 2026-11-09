import 'package:flutter/material.dart';
import 'package:untitled/screens/teamScreenStat.dart';

import '../services/standings1Service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Standings1Screen extends StatelessWidget {
  const Standings1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement constructeurs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Standings1Service.get1Standings(),
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

          final teams = snapshot.data ?? [];

          if (teams.isEmpty) {
            return const Center(
              child: Text('Aucun team disponible'),
            );
          }

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];

              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${team['position']}',
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
                      child: (team['logo'] != null &&
                          team['logo'].toString().trim().isNotEmpty)
                          ? Image.network(
                        team['logo'].toString().trim(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;

                          return const SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Erreur chargement logo : $error');

                          return const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.broken_image,
                              size: 35,
                              color: Colors.red,
                            ),
                          );
                        },
                      )
                          : const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.image_not_supported, size: 35),
                      ),
                    )
                    ,
                  ],
                ),
                title: InkWell(
                  onTap: () {
                    final teamId = team['id'];

                    if (teamId == null) {
                      debugPrint('Erreur : ID de l’équipe absent : $team');
                      return;
                    }



                    debugPrint('Équipe complète : $team');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamCareerScreen(
                          teamId: (team['id'] as num).toInt(),
                        ),
                      ),
                    );

                  },
                  child: Text(
                    '${team['constructor_name']} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),




                trailing: Text(
                  '${team['points']} pts',
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