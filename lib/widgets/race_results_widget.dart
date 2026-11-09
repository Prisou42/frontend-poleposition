
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RaceResultsWidget extends StatefulWidget {
  final int season;
  final int round;

  const RaceResultsWidget({
    super.key,
    required this.season,
    required this.round,
  });

  @override
  State<RaceResultsWidget> createState() =>
      _RaceResultsWidgetState();
}

class _RaceResultsWidgetState
    extends State<RaceResultsWidget> {

  String selectedSession = 'Q3';

  List<dynamic> results = [];

  bool isLoading = false;
  String? errorMessage;

  final String baseUrl =
      'https://poleposition-api.onrender.com';

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final isRace = selectedSession == 'Race Results';

      final endpoint = isRace
          ? '/races/${widget.season}/${widget.round}/results'
          : '/races/${widget.season}/${widget.round}/qualifying/${selectedSession}';

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur API : ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        results = isRace
            ? data['results']
            : data['qualifying'];

        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        DropdownButtonFormField<String>(
          value: selectedSession,
          decoration: const InputDecoration(
            labelText: 'Session',
            border: OutlineInputBorder(),
          ),
          items: [
            'Q1',
            'Q2',
            'Q3',
            'Race Results',
          ].map((session) {
            return DropdownMenuItem(
              value: session,
              child: Text(session),
            );
          }).toList(),

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedSession = value;
            });

            loadResults();
          },
        ),

        const SizedBox(height: 20),

        if (isLoading)
          const CircularProgressIndicator()

        else if (errorMessage != null)
          Text(errorMessage!)

        else if (results.isEmpty)
            const Text('Aucun résultat disponible')

          else
            ...results.map((driver) {
              return ListTile(
                leading: Text(
                  '${driver['position']}',
                ),
                title: Text(
                  '${driver['given_name'] ?? ''} '
                      '${driver['family_name'] ?? ''}',
                ),
                subtitle: Text(
                  driver['constructor_name'] ?? '',
                ),
                trailing: Text(
                  selectedSession == 'Race Results'
                      ? '${driver['time'] ?? '—'}'
                      : '${driver[selectedSession.toLowerCase()] ?? '—'}',
                ),
              );
            }),
      ],
    );
  }
}
