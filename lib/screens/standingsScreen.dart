
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/driverStanding.dart';
import '../services/standinsService.dart';
import '../widgets/polePositionAppBar.dart';

class DriversStandingsScreen extends StatefulWidget {
  const DriversStandingsScreen({super.key});

  @override
  State<DriversStandingsScreen> createState() =>
      _DriversStandingsScreenState();
}

class _DriversStandingsScreenState
    extends State<DriversStandingsScreen> {
  final StandingsService service = StandingsService();

  List<DriverStanding> drivers = [];
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
      final result = await service.getDriversStandings();

      if (!mounted) return;

      setState(() {
        drivers = result;
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

  Widget buildDriver(DriverStanding driver) {
    final image = StandingsService.imageUrl(driver.imageUrl);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: ListTile(
        onTap: () {
          context.push('/drivers/${driver.id}/stats');
        },
        leading: SizedBox(
          width: 62,
          child: Row(
            children: [
              SizedBox(
                width: 15,
                child: Text(
                  '${driver.position}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: image.isEmpty
                    ? const Icon(Icons.person)
                    : Image.network(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          driver.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${driver.constructorName} ',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatPoints(driver.points),
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
        title: 'Classement pilotes',
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
                      'PILOTES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (drivers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Aucun classement disponible.',
                        ),
                      ),
                    ),
                  ...drivers.map(buildDriver),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


