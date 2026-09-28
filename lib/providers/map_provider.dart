import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/demo_locations.dart';
import '../models/location_model.dart';
import '../models/route_model.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';

class MapProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  RouteService? _routeService;

  StreamSubscription<Position>? _locationSubscription;

  String _locationStatus = 'Location not checked';

  LatLng? _currentLocation;

  LocationModel? _selectedDestination;

  RouteModel? _route;

  bool _isRouteLoading = false;

  String? _routeError;

  List<Marker> _markers = [
    Marker(
      point: pickupLocation.position,
      width: 50,
      height: 50,
      child: const Icon(
        Icons.location_pin,
        size: 40,
        color: Colors.orange,
      ),
    ),
    Marker(
      point: deliveryLocation.position,
      width: 50,
      height: 50,
      child: const Icon(
        Icons.location_pin,
        size: 40,
        color: Colors.green,
      ),
    ),
  ];

  List<Polyline> _polylines = [];

  String get locationStatus => _locationStatus;

  LatLng? get currentLocation => _currentLocation;

  LocationModel? get selectedDestination => _selectedDestination;

  List<Marker> get markers => _markers;

  List<Polyline> get polylines => _polylines;

  RouteModel? get route => _route;

  bool get isRouteLoading => _isRouteLoading;

  String? get routeError => _routeError;

  Future<void> getCurrentLocation() async {
    _locationStatus = 'Getting location...';
    notifyListeners();

    final error = await _locationService.getLocationError();

    if (error != null) {
      _locationStatus = error;
      notifyListeners();
      return;
    }

    final position = await _locationService.getCurrentLocation();

    if (position == null) {
      _locationStatus = 'Unable to get current location.';
      notifyListeners();
      return;
    }

    _updateCurrentLocation(position);
  }

  void startLocationTracking() {
    _locationSubscription?.cancel();

    _locationSubscription =
        _locationService.getLocationStream().listen(
      (position) {
        _updateCurrentLocation(position);
      },
      onError: (_) {
        _locationStatus = 'Unable to track current location.';
        notifyListeners();
      },
    );
  }

  void _updateCurrentLocation(Position position) {
    _currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    _locationStatus =
        'Latitude: ${position.latitude}\n'
        'Longitude: ${position.longitude}';

    _markers = [
      Marker(
        point: _currentLocation!,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.my_location,
          size: 35,
          color: Colors.blue,
        ),
      ),
      Marker(
        point: pickupLocation.position,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          size: 40,
          color: Colors.orange,
        ),
      ),
      Marker(
        point: deliveryLocation.position,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_pin,
          size: 40,
          color: Colors.green,
        ),
      ),
    ];

    notifyListeners();

    if (_selectedDestination != null &&
        _routeService != null) {
      calculateRoute();
    }
  }

  void selectDestination(LocationModel destination) {
    _selectedDestination = destination;
    _route = null;
    _routeError = null;
    _polylines = [];

    notifyListeners();
  }

  void initializeRouteService() {
  _routeService = RouteService();
}

  Future<void> calculateRoute() async {
    if (_routeService == null) {
      _routeError = 'Route service is not configured yet.';
      notifyListeners();
      return;
    }

    if (_currentLocation == null) {
      _routeError = 'Current location is not available.';
      notifyListeners();
      return;
    }

    if (_selectedDestination == null) {
      _routeError = 'Please select a destination.';
      notifyListeners();
      return;
    }

    _isRouteLoading = true;
    _routeError = null;
    notifyListeners();

    final result = await _routeService!.getRoute(
      origin: _currentLocation!,
      destination: _selectedDestination!.position,
    );

    if (result == null) {
      _route = null;
      _polylines = [];
      _routeError = 'Unable to calculate route.';
    } else {
      _route = result;

      final points = decodePolyline(
        result.encodedPolyline,
      );

      _polylines = [
        Polyline(
          points: points,
          strokeWidth: 5,
        ),
      ];
    }

    _isRouteLoading = false;
    notifyListeners();
  }

  List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      while (true) {
        final byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLatitude =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      latitude += deltaLatitude;

      shift = 0;
      result = 0;

      while (true) {
        final byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final deltaLongitude =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      longitude += deltaLongitude;

      points.add(
        LatLng(
          latitude / 1e5,
          longitude / 1e5,
        ),
      );
    }

    return points;
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}