import 'package:latlong2/latlong.dart';

class EsnaPlace {
  final String id;
  final String name;
  final String category;
  final LatLng location;
  final String address;
  final String? phone;

  const EsnaPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.address,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'lat': location.latitude,
        'lon': location.longitude,
        'address': address,
        'phone': phone,
      };

  factory EsnaPlace.fromJson(Map<String, dynamic> json) => EsnaPlace(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        location: LatLng(json['lat'], json['lon']),
        address: json['address'],
        phone: json['phone'],
      );
}
