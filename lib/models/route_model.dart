class RouteModel {
  final double distanceInMeters;
  final int durationInSeconds;
  final String encodedPolyline;

  const RouteModel({
    required this.distanceInMeters,
    required this.durationInSeconds,
    required this.encodedPolyline,
  });

  String get distanceText {
    if (distanceInMeters >= 1000) {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }

    return '${distanceInMeters.toStringAsFixed(0)} m';
  }

  String get durationText {
    final minutes = (durationInSeconds / 60).ceil();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $remainingMinutes min';
  }
}