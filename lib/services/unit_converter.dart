import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum UnitSystem { metric, imperial }

class UnitConverter {
  /// Detect preferred unit system based on device locale
  static UnitSystem getPreferredSystem() {
    if (kIsWeb) {
      // On web, default to metric (could check browser locale)
      return UnitSystem.metric;
    }

    try {
      final locale = Platform.localeName.toLowerCase();
      // Countries that primarily use imperial
      if (locale.contains('en_us') ||
          locale.contains('en_lr') || // Liberia
          locale.contains('en_mm')) {
        // Myanmar
        return UnitSystem.imperial;
      }
    } catch (_) {
      // Platform not available
    }

    return UnitSystem.metric;
  }

  /// Format distance with appropriate units
  static String formatDistance(double meters, {UnitSystem? system}) {
    final useSystem = system ?? getPreferredSystem();

    if (useSystem == UnitSystem.imperial) {
      return _formatImperial(meters);
    } else {
      return _formatMetric(meters);
    }
  }

  static String _formatMetric(double meters) {
    if (meters < 1) {
      return '${(meters * 100).toStringAsFixed(0)} cm';
    } else if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  static String _formatImperial(double meters) {
    final feet = meters * 3.28084;
    if (feet < 5280) {
      return '${feet.toStringAsFixed(1)} ft';
    } else {
      final miles = feet / 5280;
      return '${miles.toStringAsFixed(2)} mi';
    }
  }

  /// Get just the numeric value for display
  static String getDistanceValue(double meters, {UnitSystem? system}) {
    final useSystem = system ?? getPreferredSystem();

    if (useSystem == UnitSystem.imperial) {
      final feet = meters * 3.28084;
      if (feet < 5280) {
        return feet.toStringAsFixed(0);
      } else {
        return (feet / 5280).toStringAsFixed(2);
      }
    } else {
      if (meters < 1000) {
        return meters.toStringAsFixed(0);
      } else {
        return (meters / 1000).toStringAsFixed(2);
      }
    }
  }

  /// Get just the unit label
  static String getDistanceUnit(double meters, {UnitSystem? system}) {
    final useSystem = system ?? getPreferredSystem();

    if (useSystem == UnitSystem.imperial) {
      final feet = meters * 3.28084;
      return feet < 5280 ? 'ft' : 'mi';
    } else {
      return meters < 1000 ? 'm' : 'km';
    }
  }
}
