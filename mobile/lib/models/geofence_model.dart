class GeofenceModel {
  final int id;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool active;
  final double? south, north, west, east;

  GeofenceModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.active,
    this.south, this.north, this.west, this.east,
  });

  factory GeofenceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GeofenceModel(
      id: json['id'],
      latitude:
          double.parse(json['latitude'].toString()),
      longitude:
          double.parse(json['longitude'].toString()),
      radiusMeters:
          double.parse(
            json['radius_meters'].toString(),
          ),
      active: json['active'] ?? true,
      south: json['south'] == null ? null : double.parse(json['south'].toString()),
      north: json['north'] == null ? null : double.parse(json['north'].toString()),
      west: json['west'] == null ? null : double.parse(json['west'].toString()),
      east: json['east'] == null ? null : double.parse(json['east'].toString()),
    );
  }
}

