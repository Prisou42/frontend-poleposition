class Race {
  final int id;
  final int circuitId;
  final DateTime season;
  final int round;
  final DateTime raceDate;
  final String status;

  Race({required this.id, required this.circuitId, required this.season, required this.round, required this.raceDate, required this.status});
}