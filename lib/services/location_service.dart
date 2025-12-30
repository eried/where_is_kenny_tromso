import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _distanceController = StreamController<DistanceInfo>.broadcast();

  Stream<DistanceInfo> get distanceStream => _distanceController.stream;

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startTracking() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      _distanceController.addError('Location permission denied');
      return;
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every 1 meter
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final distance = _calculate3DDistance(
        position.latitude,
        position.longitude,
        position.altitude,
        position.accuracy,
      );

      _distanceController.add(DistanceInfo(
        distanceMeters: distance,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        userAltitude: position.altitude,
        accuracy: position.accuracy,
      ));
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Check if we're likely running in an emulator
  bool _isLikelyEmulator(double altitude, double accuracy) {
    // Emulators typically report altitude as 0 and may have unusual accuracy
    // Real devices usually have some altitude data unless GPS is very poor
    if (kIsWeb) return false; // Web doesn't have emulator concept

    // If altitude is exactly 0 or very close, might be emulator
    // Real GPS rarely gives exactly 0 altitude
    if (altitude.abs() < 1 && accuracy < 100) {
      return true;
    }
    return false;
  }

  /// Calculate 3D distance using Haversine + altitude difference
  double _calculate3DDistance(
    double userLat,
    double userLon,
    double userAlt,
    double accuracy,
  ) {
    // Haversine formula for horizontal distance
    const double earthRadius = 6371000; // meters

    final lat1 = userLat * math.pi / 180;
    final lat2 = KennyLocation.latitude * math.pi / 180;
    final deltaLat =
        (KennyLocation.latitude - userLat) * math.pi / 180;
    final deltaLon =
        (KennyLocation.longitude - userLon) * math.pi / 180;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final horizontalDistance = earthRadius * c;

    // Only include altitude if we have valid altitude data
    // Skip altitude calculation if likely in emulator or altitude seems invalid
    final isEmulator = _isLikelyEmulator(userAlt, accuracy);

    if (isEmulator || userAlt.abs() < 1) {
      // Just return horizontal distance for emulators
      debugPrint('Using 2D distance (emulator/no altitude data)');
      return horizontalDistance;
    }

    // Add altitude difference using Pythagorean theorem
    final altitudeDiff = KennyLocation.altitude - userAlt;
    final distance3D =
        math.sqrt(horizontalDistance * horizontalDistance + altitudeDiff * altitudeDiff);

    return distance3D;
  }

  void dispose() {
    stopTracking();
    _distanceController.close();
  }
}

class DistanceInfo {
  final double distanceMeters;
  final double userLatitude;
  final double userLongitude;
  final double userAltitude;
  final double accuracy;

  DistanceInfo({
    required this.distanceMeters,
    required this.userLatitude,
    required this.userLongitude,
    required this.userAltitude,
    required this.accuracy,
  });

  /// Get distance in appropriate unit based on size
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(1)} m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Get distance in imperial units
  String get formattedDistanceImperial {
    final feet = distanceMeters * 3.28084;
    if (feet < 5280) {
      return '${feet.toStringAsFixed(1)} ft';
    } else {
      return '${(feet / 5280).toStringAsFixed(2)} mi';
    }
  }
}
