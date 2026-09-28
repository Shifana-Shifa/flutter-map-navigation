# Flutter Map & Navigation Integration Test

A Flutter mobile application demonstrating map integration, current-location tracking, destination selection, route calculation, and route visualization using Google Maps.

## Features

* Google Maps integration
* Current location detection
* Location permission handling
* GPS/location-service status handling
* Current location marker
* Pickup location marker
* Delivery location marker
* Navigate to Pickup
* Navigate to Delivery
* Route calculation from current location to selected destination
* Route distance display
* Estimated travel time display
* Route polyline visualization
* Location tracking and marker updates
* Route recalculation when the user's location changes
* Route and location error handling

## Maps SDK / API

### Google Maps

**Selected technology:**

* Google Maps SDK for Android
* Google Maps Routes API

Google Maps was selected because it provides Flutter support through the `google_maps_flutter` package and provides routing functionality through the Google Routes API.

## Flutter Packages

The project uses the following packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  google_maps_flutter:
  geolocator:
  flutter_polyline_points:
  provider:
  http:
```

### Package Usage

| Package                   | Purpose                                     |
| ------------------------- | ------------------------------------------- |
| `google_maps_flutter`     | Displays Google Maps and map markers        |
| `geolocator`              | Gets and tracks the user's current location |
| `flutter_polyline_points` | Decodes the route polyline                  |
| `provider`                | Manages map and location state              |
| `http`                    | Sends requests to the Google Routes API     |

## Architecture

The application follows a simple Provider-based structure:

```text
UI
 │
 ▼
MapProvider
 │
 ├── LocationService
 │
 └── RouteService
      │
      ▼
 Google Routes API
```

### Project Structure

```text
lib/
├── data/
│   └── demo_locations.dart
│
├── models/
│   ├── location_model.dart
│   └── route_model.dart
│
├── providers/
│   └── map_provider.dart
│
├── services/
│   ├── location_service.dart
│   └── route_service.dart
│
└── main.dart
```

## Location Handling

The application uses `geolocator` to:

1. Check whether location services are enabled.
2. Check location permissions.
3. Request permission when required.
4. Handle denied and permanently denied permissions.
5. Get the current location.
6. Continuously track location changes.

The current location is displayed using a dedicated map marker.

## Destination Locations

The application contains two destination locations:

* **Pickup Location**
* **Delivery Location**

Each destination has its own marker and can be selected using the corresponding navigation button.

## Routing Implementation

When the user selects a destination:

```text
Current Location
       │
       ▼
Selected Destination
       │
       ▼
Google Routes API
       │
       ├── Distance
       ├── Duration
       └── Encoded Polyline
```

The application sends the current location and selected destination to the Google Routes API.

The returned route information is used to display:

* Distance
* Estimated travel time
* Route line on the map

The encoded polyline returned by the API is decoded and displayed using a Google Maps `Polyline`.

## Location Change Handling

The application listens for location changes using `Geolocator.getPositionStream()`.

When the user's location changes:

1. The current-location marker is updated.
2. The current coordinates are updated.
3. If a destination is selected, the route is recalculated.

This allows the displayed route to respond to changes in the user's location.

## Error Handling

The application handles the following cases:

### Location Services Disabled

The user is informed that GPS/location services need to be enabled.

### Location Permission Denied

The application displays an appropriate permission error.

### Location Permission Permanently Denied

The application informs the user that permission needs to be enabled through device settings.

### Location Unavailable

The application displays an error when the current location cannot be obtained.

### Route/API Failure

If the route cannot be calculated, the application displays an appropriate route error instead of crashing.

## Android Permissions

The application requires the following Android permissions:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd map_navigation_test
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps

A valid Google Maps API key is required for the Google Maps Android SDK.

The required Google Maps and Routes API services must be enabled in Google Cloud.

### 4. Run the application

Connect an Android device or start an Android emulator and run:

```bash
flutter run
```

## Testing

The following scenarios should be tested:

* Location permission allowed
* Location permission denied
* Location services disabled
* Current location displayed
* Pickup destination selected
* Delivery destination selected
* Route displayed
* Distance displayed
* Estimated travel time displayed
* Location changes reflected on the map
* Route recalculation after location changes
* Route/API failure handled without crashing

## Build APK

To generate a release APK:

```bash
flutter build apk --release
```

The generated APK can be found under:

```text
build/app/outputs/flutter-apk/release/
