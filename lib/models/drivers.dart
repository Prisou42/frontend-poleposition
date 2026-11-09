class Driver {
  final int id;
  final String firstName;
  final String lastName;
  final int number;
  final String nationality;
  final DateTime dateOfBirth;
  final String imageUrl;
  final int gpStarts;
  final int? wins;
  final int? podiums;
  final int? poles;
  final int? fastestLaps;
  final int? championships;
  final int careerPoints;
  final bool isFavorite;

  Driver({required this.id,
    required this.firstName,
    required this.lastName,
    required this.number,
    required this.nationality,
    required this.dateOfBirth,
    required this.imageUrl,
     required this.gpStarts,
     this.wins,
     this.podiums,
     this.poles,
     this.fastestLaps,
     this.championships,
     required this.careerPoints,
     required this.isFavorite});
}
List<Driver> _createDrivers() {
  final contacts1 = {
    "Charles": "Leclerc",
    "Lewis": "Hamilton",

    "Kimi": "Antonelli",
  }.entries.map((c) => Driver(
      firstName: c.key,
      lastName: c.value,
      id: 1,
      number: 16,
      nationality: 'Monaco',
      dateOfBirth: DateTime(1997, 10, 16),
      imageUrl: '',
      gpStarts: 150,
      wins: 8,
      podiums: 50,
      poles: 27,
      fastestLaps: 18,
      championships: 0,
      careerPoints: 350, isFavorite: false));

  final contacts2 = [
    for (var i = 0; i < 1000; i++)
      Driver(firstName: "Driver ${i + 1}", lastName: "Hamilton", id: 1, number: 44, nationality: 'english', dateOfBirth: DateTime(1985, 1, 7), imageUrl: '', gpStarts: 400, wins: 106, podiums: 206, poles: 105, fastestLaps: 55, championships: 7, careerPoints: 4500, isFavorite: true)
  ];

  final contacts3 = List.generate(10, (i) => Driver(firstName: "C$i", lastName: "$i", id: 3, number: 18, nationality: 'belgian', dateOfBirth: DateTime(1997,10,16), imageUrl: '', gpStarts: 175, wins: 8, podiums: 50, poles: 27, fastestLaps: 30, championships: null, careerPoints: 1500, isFavorite: true));

  return [...contacts1, ...contacts2, ...contacts3];
}

final defaultContacts = _createDrivers();