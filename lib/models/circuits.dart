class Circuit {
  final int id;
  final String name;
  final String country;
  final String city;
  final double lengthKm;
  final int laps;
  final String? lapRecord;
  final String imageUrl;


  Circuit({required this.id, required this.name, required this.country, required this.city, required this.lengthKm, required this.laps,  this.lapRecord, required this.imageUrl});
}