import 'package:latlong2/latlong.dart';

class LocationModel {
  final String name;
  final LatLng position;

  const LocationModel({
    required this.name,
    required this.position,
  });
}