/// Kenny's location in Tromsoe, Norway
class KennyLocation {
  static const double latitude = 69.705561;
  static const double longitude = 18.832721;
  static const double altitude = 488.8; // meters

  KennyLocation._();
}

/// App configuration
class AppConfig {
  static const String appName = 'Where Is Kenny?';
  static const String appVersion = '1.0.0';

  /// Distance thresholds for color coding (in meters)
  static const double closeDistance = 100;
  static const double mediumDistance = 1000;
  static const double farDistance = 10000;

  /// Beep settings
  static const double minBeepInterval = 0.1; // seconds at closest
  static const double maxBeepInterval = 2.0; // seconds at farthest
  static const double beepDistanceRange = 1000; // meters for full pitch range

  AppConfig._();
}
