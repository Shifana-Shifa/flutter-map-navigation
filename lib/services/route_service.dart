import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_model.dart';

class RouteService {
  Future<RouteModel?> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' ||
          data['routes'] == null ||
          data['routes'].isEmpty) {
        return null;
      }

      final route = data['routes'][0];

      return RouteModel(
        distanceInMeters:
            (route['distance'] as num).toDouble(),
        durationInSeconds:
            (route['duration'] as num).round(),
        encodedPolyline:
            route['geometry'] as String,
      );
    } catch (_) {
      return null;
    }
  }
}