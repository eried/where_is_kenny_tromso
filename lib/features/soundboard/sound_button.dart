import 'package:flutter/material.dart';

class SoundButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const SoundButton({
    super.key,
    required this.label,
    required this.icon,
    this.color,
    required this.onPressed,
  });

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _shouldReverse = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // When forward animation completes, reverse if needed
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _shouldReverse) {
        _shouldReverse = false;
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _isPressed = true);
    _shouldReverse = false;
    _controller.forward();
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    widget.onPressed();

    // If animation hasn't completed, wait for it to complete then reverse
    if (_controller.status == AnimationStatus.forward) {
      _shouldReverse = true;
    } else {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    // Still complete the push animation on cancel
    if (_controller.status == AnimationStatus.forward) {
      _shouldReverse = true;
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Colors.orange;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                buttonColor.withValues(alpha: _isPressed ? 0.6 : 0.8),
                buttonColor.withValues(alpha: _isPressed ? 0.4 : 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 36,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Waveform animation overlay for playing sounds
class WaveformOverlay extends StatefulWidget {
  final bool isPlaying;

  const WaveformOverlay({super.key, required this.isPlaying});

  @override
  State<WaveformOverlay> createState() => _WaveformOverlayState();
}

class _WaveformOverlayState extends State<WaveformOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WaveformOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final delay = index * 0.1;
            final value =
                ((_controller.value + delay) % 1.0 * 2 - 1).abs();
            return Container(
              width: 3,
              height: 10 + (value * 10),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
