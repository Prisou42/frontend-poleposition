
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/constructorStanding.dart';
import '../services/standinsService.dart';
import '../widgets/polePositionAppBar.dart';

class ConstructorsStandingsScreen extends StatefulWidget {
  const ConstructorsStandingsScreen({super.key});

  @override
  State<ConstructorsStandingsScreen> createState() =>
      _ConstructorsStandingsScreenState();
}

class _ConstructorsStandingsScreenState
    extends State<ConstructorsStandingsScreen> {
  final StandingsService service = StandingsService();

  List<ConstructorStanding> constructors = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadStandings();
  }

  Future<void> loadStandings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await service.getConstructorsStandings();

      if (!mounted) return;

      setState(() {
        constructors = result;
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

  String formatPoints(double points) {
    return points % 1 == 0
        ? points.toStringAsFixed(0)
        : points.toStringAsFixed(2);
  }

  Widget buildConstructor(ConstructorStanding team) {
    final logo = StandingsService.imageUrl(team.logo);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: ListTile(
        onTap: () {
          context.push('/teams/${team.id}/stats');
        },
        leading: SizedBox(
          width: 75,
          child: Row(
            children: [
              SizedBox(
                width: 12,
                child: Text(
                  '${team.position}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: logo.isEmpty
                    ? const Icon(Icons.directions_car)
                    : Image.network(
                  logo,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.directions_car),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          team.constructorName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatPoints(team.points),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'PTS',
              style: TextStyle(fontSize: 10),
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
        title: 'Classement constructeurs',
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: isLoading ? null : loadStandings,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loadStandings,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: loadStandings,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'CONSTRUCTEURS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (constructors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Aucun classement disponible.',
                        ),
                      ),
                    ),
                  ...constructors.map(buildConstructor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
