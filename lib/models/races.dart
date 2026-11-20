
class Race {
  final int id;
  final int season;
  final int round;
  final String circuitImage;
  final String raceName;
  final DateTime raceDate;
  final String raceTime;

  Race({
    required this.id,
    required this.season,
    required this.round,
    required this.circuitImage,
    required this.raceName,
    required this.raceDate,
    required this.raceTime,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: int.tryParse(json['id'].toString()) ?? 0,
      season: int.tryParse(json['season'].toString()) ?? 2026,
      round: int.tryParse(json['round'].toString()) ?? 0,
      circuitImage: json['circuit_image']?.toString() ?? '',
      raceName: json['race_name']?.toString() ?? '',
      raceDate: DateTime.parse(json['race_date'].toString()),
      raceTime: json['race_time']?.toString() ?? '',
    );
  }

  String get formattedDate {
    final date = raceDate.toLocal();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get formattedTime {
    if (raceTime.length >= 5) {
      return raceTime.substring(0, 5);
    }
    return raceTime;
  }
}
