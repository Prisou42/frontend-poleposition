
class RaceDetails {
  final int season;
  final int round;
  final String circuitTimezone;
  final String raceName;

  final String raceDate;
  final String raceTime;

  final String? fp1Date;
  final String? fp1Time;

  final String? fp2Date;
  final String? fp2Time;

  final String? fp3Date;
  final String? fp3Time;

  final String? qualifyingDate;
  final String? qualifyingTime;

  final String? sprintQualifyingDate;
  final String? sprintQualifyingTime;

  final String? sprintDate;
  final String? sprintTime;

  RaceDetails({
    required this.season,
    required this.round,
    required this.circuitTimezone,
    required this.raceName,
    required this.raceDate,
    required this.raceTime,
    this.fp1Date,
    this.fp1Time,
    this.fp2Date,
    this.fp2Time,
    this.fp3Date,
    this.fp3Time,
    this.qualifyingDate,
    this.qualifyingTime,
    this.sprintQualifyingDate,
    this.sprintQualifyingTime,
    this.sprintDate,
    this.sprintTime,
  });

  factory RaceDetails.fromJson(Map<String, dynamic> json) {
    return RaceDetails(
      season: int.tryParse(json['season'].toString()) ?? 2026,
      round: int.tryParse(json['round'].toString()) ?? 0,
      circuitTimezone: json['circuit_timezone']?.toString() ?? 'UTC',
      raceName: json['race_name']?.toString() ?? '',
      raceDate: json['race_date']?.toString() ?? '',
      raceTime: json['race_time']?.toString() ?? '',
      fp1Date: json['fp1_date']?.toString(),
      fp1Time: json['fp1_time']?.toString(),
      fp2Date: json['fp2_date']?.toString(),
      fp2Time: json['fp2_time']?.toString(),
      fp3Date: json['fp3_date']?.toString(),
      fp3Time: json['fp3_time']?.toString(),
      qualifyingDate: json['qualifying_date']?.toString(),
      qualifyingTime: json['qualifying_time']?.toString(),
      sprintQualifyingDate: json['sprint_qualifying_date']?.toString(),
      sprintQualifyingTime: json['sprint_qualifying_time']?.toString(),
      sprintDate: json['sprint_date']?.toString(),
      sprintTime: json['sprint_time']?.toString(),
    );
  }
}
