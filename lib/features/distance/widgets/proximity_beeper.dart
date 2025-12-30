import 'package:flutter/material.dart';
import '../../../services/audio_service.dart';

class ProximityBeeperToggle extends StatefulWidget {
  final AudioService audioService;
  final double distanceMeters;
  final bool initialEnabled;
  final ValueChanged<bool>? onToggled;

  const ProximityBeeperToggle({
    super.key,
    required this.audioService,
    required this.distanceMeters,
    this.initialEnabled = false,
    this.onToggled,
  });

  @override
  State<ProximityBeeperToggle> createState() => _ProximityBeeperToggleState();
}

class _ProximityBeeperToggleState extends State<ProximityBeeperToggle> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialEnabled;
    if (_isEnabled) {
      widget.audioService.startProximityBeep(widget.distanceMeters);
    }
  }

  void _toggleBeeper() {
    setState(() {
      _isEnabled = !_isEnabled;
      if (_isEnabled) {
        widget.audioService.startProximityBeep(widget.distanceMeters);
      } else {
        widget.audioService.stopProximityBeep();
      }
      widget.onToggled?.call(_isEnabled);
    });
  }

  @override
  void didUpdateWidget(ProximityBeeperToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEnabled && widget.distanceMeters != oldWidget.distanceMeters) {
      widget.audioService.updateProximityBeep(widget.distanceMeters);
    }
  }

  @override
  void dispose() {
    if (_isEnabled) {
      widget.audioService.stopProximityBeep();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _toggleBeeper,
          iconSize: 48,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isEnabled ? Icons.volume_up : Icons.volume_off,
              key: ValueKey(_isEnabled),
              color: _isEnabled ? Colors.orange : Colors.grey,
            ),
          ),
        ),
        Text(
          _isEnabled ? 'Sound ON' : 'Sound OFF',
          style: TextStyle(
            fontSize: 12,
            color: _isEnabled ? Colors.orange : Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Visual proximity indicator with pulsing animation
class ProximityIndicator extends StatefulWidget {
  final double distanceMeters;
  final double maxDistance;

  const ProximityIndicator({
    super.key,
    required this.distanceMeters,
    this.maxDistance = 1000,
  });

  @override
  State<ProximityIndicator> createState() => _ProximityIndicatorState();
}

class _ProximityIndicatorState extends State<ProximityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _updateAnimationSpeed();
  }

  void _updateAnimationSpeed() {
    // Faster pulse when closer
    final normalizedDistance =
        (widget.distanceMeters / widget.maxDistance).clamp(0.0, 1.0);
    final durationMs = 200 + (normalizedDistance * 1800).toInt();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ProximityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.distanceMeters != oldWidget.distanceMeters) {
      _controller.dispose();
      _updateAnimationSpeed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedDistance =
        (widget.distanceMeters / widget.maxDistance).clamp(0.0, 1.0);
    final color = Color.lerp(Colors.green, Colors.red, normalizedDistance)!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5 * _animation.value),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
