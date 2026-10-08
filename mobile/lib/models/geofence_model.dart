class GeofenceModel {
  final int id;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool active;

  GeofenceModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.active,
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
    );
  }
}

