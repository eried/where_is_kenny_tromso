import 'package:flutter/material.dart';
import '../../../services/unit_converter.dart';
import '../../../config/constants.dart';

/// Animated distance display with smooth 10-second counting animation
class AnimatedDistanceDisplayFancy extends StatefulWidget {
  final double distanceMeters;
  final UnitSystem? unitSystem;

  const AnimatedDistanceDisplayFancy({
    super.key,
    required this.distanceMeters,
    this.unitSystem,
  });

  @override
  State<AnimatedDistanceDisplayFancy> createState() =>
      _AnimatedDistanceDisplayFancyState();
}

class _AnimatedDistanceDisplayFancyState
    extends State<AnimatedDistanceDisplayFancy>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _displayedDistance = 0;
  double _targetDistance = 0;
  double _startDistance = 0;

  @override
  void initState() {
    super.initState();
    _displayedDistance = _getEffectiveDistance(widget.distanceMeters);
    _targetDistance = _displayedDistance;
    _startDistance = _displayedDistance;

    // 10-second smooth counting animation
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _countController.addListener(_updateDisplayedDistance);

    // Pulse animation for visual feedback
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  void _updateDisplayedDistance() {
    setState(() {
      _displayedDistance = _startDistance +
          (_targetDistance - _startDistance) * _countController.value;
    });
  }

  /// Get effective distance (show 0 if under 5 meters)
  double _getEffectiveDistance(double meters) {
    return meters < 5 ? 0 : meters;
  }

  @override
  void didUpdateWidget(AnimatedDistanceDisplayFancy oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newTarget = _getEffectiveDistance(widget.distanceMeters);

    // Only animate if target changed significantly
    if ((newTarget - _targetDistance).abs() > 0.5) {
      _startDistance = _displayedDistance;
      _targetDistance = newTarget;
      _countController.reset();
      _countController.forward();

      // Pulse effect
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getDistanceColor() {
    final distance = _displayedDistance;
    if (distance <= AppConfig.closeDistance) {
      return Colors.green;
    } else if (distance <= AppConfig.mediumDistance) {
      final t = (distance - AppConfig.closeDistance) /
          (AppConfig.mediumDistance - AppConfig.closeDistance);
      return Color.lerp(Colors.green, Colors.orange, t)!;
    } else if (distance <= AppConfig.farDistance) {
      final t = (distance - AppConfig.mediumDistance) /
          (AppConfig.farDistance - AppConfig.mediumDistance);
      return Color.lerp(Colors.orange, Colors.red, t)!;
    } else {
      return Colors.red;
    }
  }

  /// Calculate font scale based on distance - bigger when closer!
  double _getFontScale() {
    final distance = _displayedDistance;
    // Scale from 1.0 (far) to 2.0 (very close)
    // Start scaling up at 1km, max scale at 10m
    if (distance > 1000) {
      return 1.0;
    } else if (distance > 100) {
      // 100m - 1km: scale from 1.0 to 1.3
      final t = 1 - (distance - 100) / 900;
      return 1.0 + (t * 0.3);
    } else if (distance > 50) {
      // 50m - 100m: scale from 1.3 to 1.5
      final t = 1 - (distance - 50) / 50;
      return 1.3 + (t * 0.2);
    } else if (distance > 10) {
      // 10m - 50m: scale from 1.5 to 1.8
      final t = 1 - (distance - 10) / 40;
      return 1.5 + (t * 0.3);
    } else {
      // < 10m: scale from 1.8 to 2.0
      final t = 1 - distance / 10;
      return 1.8 + (t * 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = UnitConverter.getDistanceValue(_displayedDistance, system: widget.unitSystem);
    final unit = UnitConverter.getDistanceUnit(_displayedDistance, system: widget.unitSystem);
    final color = _getDistanceColor();

    // Special display for 0 (reached Kenny!)
    if (_displayedDistance == 0) {
      return _buildReachedKennyDisplay();
    }

    final fontScale = _getFontScale();
    final baseFontSize = 110.0;
    final baseUnitSize = 48.0;
    final scaledFontSize = baseFontSize * fontScale;
    final scaledUnitSize = baseUnitSize * fontScale;

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big number with unit inline
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: scaledFontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: scaledUnitSize,
                    fontWeight: FontWeight.w700,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReachedKennyDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.green, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            '0',
            style: TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
          ),
          child: const Text(
            'YOU FOUND KENNY!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}
