
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled/models/races.dart';
import 'package:untitled/services/raceService.dart';
import '../widgets/polePositionAppBar.dart';

class RacesScreen extends StatefulWidget {
  const RacesScreen({super.key});

  @override
  State<RacesScreen> createState() => _RacesScreenState();
}

class _RacesScreenState extends State<RacesScreen> {
  final RacesService service = RacesService();

  List<Race> races = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadRaces();
  }

  Future<void> loadRaces() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await service.getRaces();

      if (!mounted) return;

      setState(() {
        races = result;
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

  Widget buildRace(Race race) {
    final imageUrl = RacesService.imageUrl(race.circuitImage);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/races/${race.season}/${race.round}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              SizedBox(
                height: 155,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(
                        Icons.flag,
                        size: 45,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${race.round}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          race.raceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${race.formattedDate} • ${race.formattedTime}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
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
      appBar: const PolePositionAppBar(
        title: 'Calendrier F1 2026',
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: isLoading ? null : loadRaces,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser',
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : error != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: loadRaces,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: loadRaces,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'SAISON 2026',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (races.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun Grand Prix disponible.',
                        ),
                      ),
                    ),
                  ...races.map(buildRace),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
