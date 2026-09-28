import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'data/demo_locations.dart';
import 'providers/map_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MapProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Navigation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MapProvider>();

      provider.initializeRouteService();
      provider.getCurrentLocation();
      provider.startLocationTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Navigation'),
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(12.9716, 77.5946),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.map_navigation_test',
                  ),

                  PolylineLayer(
                    polylines: provider.polylines
                        .map(
                          (polyline) => Polyline(
                            points: polyline.points,
                            strokeWidth: 5,
                          ),
                        )
                        .toList(),
                  ),

                  MarkerLayer(
                    markers: provider.markers,
                  ),
                ],
              ),

              Positioned(
                top: 20,
                left: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            const Text('Current Location'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            const Text('Pickup'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            const Text('Delivery'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.selectedDestination != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Destination: '
                            '${provider.selectedDestination!.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        if (provider.isRouteLoading) ...[
                          const SizedBox(height: 6),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          ),
                        ],

                        if (provider.route != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Distance: '
                                '${provider.route!.distanceText}',
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'ETA: '
                                '${provider.route!.durationText}',
                              ),
                            ],
                          ),
                        ],

                        if (provider.routeError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            provider.routeError!,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 6),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade900,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: provider.isRouteLoading
                              ? null
                              : () async {
                                  await provider.getCurrentLocation();

                                  if (provider.currentLocation != null) {
                                    _mapController.move(
                                      provider.currentLocation!,
                                      15,
                                    );
                                  }
                                },
                          child: const Text(
                            'Get Current Location',
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade100,
                                  foregroundColor: Colors.orange.shade900,
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: provider.isRouteLoading
                                    ? null
                                    : () async {
                                        provider.selectDestination(
                                          pickupLocation,
                                        );
                                        await provider.calculateRoute();
                                      },
                                child: Text(
                                  provider.isRouteLoading &&
                                          provider.selectedDestination ==
                                              pickupLocation
                                      ? 'Calculating...'
                                      : 'Navigate to Pickup',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade100,
                                  foregroundColor: Colors.green.shade900,
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: provider.isRouteLoading
                                    ? null
                                    : () async {
                                        provider.selectDestination(
                                          deliveryLocation,
                                        );
                                        await provider.calculateRoute();
                                      },
                                child: Text(
                                  provider.isRouteLoading &&
                                          provider.selectedDestination ==
                                              deliveryLocation
                                      ? 'Calculating...'
                                      : 'Navigate to Delivery',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
