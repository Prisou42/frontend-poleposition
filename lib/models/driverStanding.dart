
class DriverStanding {
  final int id;
  final String firstName;
  final String lastName;
  final String imageUrl;
  final int season;
  final int round;
  final int position;
  final double points;
  final int wins;
  final String constructorName;

  DriverStanding({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.season,
    required this.round,
    required this.position,
    required this.points,
    required this.wins,
    required this.constructorName,
  });

  factory DriverStanding.fromJson(Map<String, dynamic> json) {
    return DriverStanding(
      id: json['id'] as int,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      season: int.tryParse(json['season'].toString()) ?? 2026,
      round: int.tryParse(json['round'].toString()) ?? 0,
      position: int.tryParse(json['position'].toString()) ?? 0,
      points: double.tryParse(json['points'].toString()) ?? 0,
      wins: int.tryParse(json['wins'].toString()) ?? 0,
      constructorName: json['constructor_name']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}
