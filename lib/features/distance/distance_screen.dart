import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/audio_service.dart';
import '../../services/unit_converter.dart';
import '../../services/settings_service.dart';
import '../../config/distance_messages.dart';
import '../about/about_screen.dart';
import 'widgets/animated_distance.dart';
import 'widgets/proximity_beeper.dart';

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({super.key});

  @override
  State<DistanceScreen> createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  final LocationService _locationService = LocationService();
  final AudioService _audioService = AudioService();
  StreamSubscription<DistanceInfo>? _distanceSubscription;

  DistanceInfo? _currentDistance;
  LocationError? _error;
  bool _isLoading = true;
  late UnitSystem _unitSystem;
  late bool _soundEnabled;
  String _currentMessage = "Mmmph mmph mmmph!";
  double _lastMessageDistance = -1;

  // Distance threshold for "too far away" (100km)
  static const double _tooFarThreshold = 100000;

  // Kenny-themed loading messages
  static const List<String> _loadingMessages = [
    "Mmmph mmph mmmph!",
    "Where's Kenny?",
    "Oh my God, where's Kenny?!",
    "Kenny? KENNY!",
    "Looking for the orange parka...",
    "Scanning for muffled sounds...",
  ];

  @override
  void initState() {
    super.initState();
    // Load saved settings
    _unitSystem = settingsService.unitSystem;
    _soundEnabled = settingsService.soundEnabled;

    // Setup auto-stop callback
    _audioService.onReachedKenny = () {
      if (mounted) {
        // Schedule after frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _soundEnabled = false;
              settingsService.soundEnabled = false;
            });
          }
        });
      }
    };

    _startTracking();
  }

  Future<void> _startTracking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _distanceSubscription = _locationService.distanceStream.listen(
      (distance) {
        setState(() {
          _currentDistance = distance;
          _isLoading = false;
          _error = null;
          // Update message when distance changes significantly (10% change)
          final distanceChange = (_lastMessageDistance - distance.distanceMeters).abs();
          if (_lastMessageDistance < 0 || distanceChange > _lastMessageDistance * 0.1 || distanceChange > 50) {
            _currentMessage = DistanceMessages.getMessage(distance.distanceMeters);
            _lastMessageDistance = distance.distanceMeters;
          }
        });
      },
      onError: (error) {
        setState(() {
          if (error is LocationError) {
            _error = error;
          } else {
            _error = LocationError(
              LocationErrorType.permissionDenied,
              error.toString(),
            );
          }
          _isLoading = false;
        });
      },
    );

    await _locationService.startTracking();
  }

  void _toggleUnits() {
    setState(() {
      _unitSystem = _unitSystem == UnitSystem.metric
          ? UnitSystem.imperial
          : UnitSystem.metric;
      settingsService.unitSystem = _unitSystem;
    });
  }

  void _onSoundToggled(bool enabled) {
    setState(() {
      _soundEnabled = enabled;
      settingsService.soundEnabled = enabled;
    });
  }

  void _showAccuracyInfo() {
    final accuracy = _currentDistance?.accuracy ?? 0;
    final isGood = accuracy < 20;
    final isMedium = accuracy >= 20 && accuracy < 50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isGood ? Icons.gps_fixed : (isMedium ? Icons.gps_not_fixed : Icons.gps_off),
              color: isGood ? Colors.green : (isMedium ? Colors.orange : Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'GPS Accuracy',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current accuracy: ${accuracy.toStringAsFixed(1)} meters',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildAccuracyRow(Icons.gps_fixed, Colors.green, '< 20m', 'Excellent'),
            _buildAccuracyRow(Icons.gps_not_fixed, Colors.orange, '20-50m', 'Good'),
            _buildAccuracyRow(Icons.gps_off, Colors.red, '> 50m', 'Poor'),
            const SizedBox(height: 16),
            Text(
              isGood
                  ? 'Your GPS signal is excellent! Distance readings are very accurate.'
                  : isMedium
                      ? 'GPS signal is good. Distance may vary by a few meters.'
                      : 'GPS signal is weak. Try moving to an open area for better accuracy.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyRow(IconData icon, Color color, String range, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(range, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const Spacer(),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  IconData _getErrorIcon(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        return Icons.gps_off;
      case LocationErrorType.permissionDenied:
        return Icons.location_off;
      case LocationErrorType.permissionDeniedForever:
        return Icons.block;
      case LocationErrorType.reducedAccuracy:
        return Icons.gps_not_fixed;
    }
  }

  String _getErrorTitle(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        return 'GPS is Off';
      case LocationErrorType.permissionDenied:
        return 'Location Access Needed';
      case LocationErrorType.permissionDeniedForever:
        return 'Location Blocked';
      case LocationErrorType.reducedAccuracy:
        return 'Precise Location Needed';
    }
  }

  IconData _getActionIcon(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        return Icons.settings;
      case LocationErrorType.permissionDenied:
        return Icons.my_location;
      case LocationErrorType.permissionDeniedForever:
        return Icons.settings;
      case LocationErrorType.reducedAccuracy:
        return Icons.settings;
    }
  }

  String _getActionLabel(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        return 'Enable GPS';
      case LocationErrorType.permissionDenied:
        return 'Grant Permission';
      case LocationErrorType.permissionDeniedForever:
        return 'Open Settings';
      case LocationErrorType.reducedAccuracy:
        return 'Open Settings';
    }
  }

  Future<void> _handleErrorAction(LocationErrorType type) async {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        await Geolocator.openLocationSettings();
        break;
      case LocationErrorType.permissionDenied:
        // Try requesting permission again
        _startTracking();
        break;
      case LocationErrorType.permissionDeniedForever:
      case LocationErrorType.reducedAccuracy:
        await Geolocator.openAppSettings();
        break;
    }
  }

  @override
  void dispose() {
    _distanceSubscription?.cancel();
    _locationService.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              _loadingMessages[DateTime.now().second % _loadingMessages.length],
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getErrorIcon(_error!.type),
                size: 64,
                color: _error!.type == LocationErrorType.reducedAccuracy
                    ? Colors.orange
                    : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorTitle(_error!.type),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              // Primary action button
              ElevatedButton.icon(
                onPressed: () => _handleErrorAction(_error!.type),
                icon: Icon(_getActionIcon(_error!.type)),
                label: Text(_getActionLabel(_error!.type)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              // Secondary action for settings-related errors
              if (_error!.type == LocationErrorType.permissionDeniedForever ||
                  _error!.type == LocationErrorType.reducedAccuracy) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _startTracking,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Check Again'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final distance = _currentDistance?.distanceMeters ?? 0;
    final isTooFar = distance > _tooFarThreshold;
    final accuracy = _currentDistance?.accuracy ?? 0;
    final accuracyColor = accuracy < 20 ? Colors.green : (accuracy < 50 ? Colors.orange : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Header with info button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Text(
                  'Distance to Kenny',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Finnlandsfjellet, Tromsø',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          // Main distance display or "too far" message
          if (isTooFar)
            _buildTooFarMessage()
          else
            AnimatedDistanceDisplayFancy(
              distanceMeters: distance,
              unitSystem: _unitSystem,
            ),
          const SizedBox(height: 24),
          // Direction indicator with random message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _currentMessage,
              key: ValueKey(_currentMessage),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Unit toggle
              Column(
                children: [
                  IconButton(
                    onPressed: _toggleUnits,
                    iconSize: 48,
                    icon: Icon(
                      _unitSystem == UnitSystem.metric
                          ? Icons.straighten
                          : Icons.square_foot,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    _unitSystem == UnitSystem.metric ? 'Metric' : 'Imperial',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              // Proximity beeper
              ProximityBeeperToggle(
                audioService: _audioService,
                distanceMeters: distance,
                initialEnabled: _soundEnabled,
                onToggled: _onSoundToggled,
              ),
              // Accuracy indicator (tappable)
              GestureDetector(
                onTap: _showAccuracyInfo,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accuracyColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          accuracy.toStringAsFixed(0),
                          style: TextStyle(
                            color: accuracyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accuracy (m)',
                      style: TextStyle(
                        fontSize: 14,
                        color: accuracyColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTooFarMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.travel_explore,
          size: 90,
          color: Colors.orange.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 16),
        const Text(
          "You're too far away!",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Come closer to Norway",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
