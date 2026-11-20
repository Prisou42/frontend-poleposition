
class ConstructorStanding {
  final int id;
  final int position;
  final String logo;
  final String constructorName;
  final double points;

  ConstructorStanding({
    required this.id,
    required this.position,
    required this.logo,
    required this.constructorName,
    required this.points,
  });

  factory ConstructorStanding.fromJson(Map<String, dynamic> json) {
    return ConstructorStanding(
      id: json['id'] as int,
      position: int.tryParse(json['position'].toString()) ?? 0,
      logo: json['logo']?.toString() ?? '',
      constructorName: json['constructor_name']?.toString() ?? '',
      points: double.tryParse(json['points'].toString()) ?? 0,
    );
  }
}
