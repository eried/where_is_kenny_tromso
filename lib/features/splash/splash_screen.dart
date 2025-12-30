import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Navigate after splash
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kenny Icon
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange
                                .withValues(alpha: 0.5 * _glowAnimation.value),
                            blurRadius: 30 * _glowAnimation.value,
                            spreadRadius: 10 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: KennyHoodPainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    'Where Is Kenny?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _fadeAnimation.value * 0.7,
                  child: Text(
                    'Finnlandsfjellet, Tromsø',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Loading indicator
                Opacity(
                  opacity: _glowAnimation.value,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for Kenny's hooded face silhouette
class KennyHoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hoodRadius = size.width * 0.35;

    // Hood outline (darker orange)
    final hoodPaint = Paint()
      ..color = const Color.fromARGB(255, 87, 36, 0)
      ..style = PaintingStyle.fill;
    //  ..strokeWidth = 4;

    canvas.drawCircle(center, hoodRadius, hoodPaint);

    // Hood fill
    final hoodFillPaint = Paint()
      ..color = const Color.fromARGB(255, 126, 48, 0)
      ..style = PaintingStyle.fill;

    // Draw hood shape (oval with fur trim at top)
    final hoodPath = Path();
    hoodPath.addOval(Rect.fromCircle(center: center, radius: hoodRadius));
    canvas.drawPath(hoodPath, hoodFillPaint);

    // Face opening (dark oval where face would be)
    final faceOpeningPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 210, 165)
      ..style = PaintingStyle.fill;

    final faceCenter = Offset(center.dx, center.dy + 5);
    final faceRect = Rect.fromCenter(
      center: faceCenter,
      width: size.width * 0.35,
      height: size.height * 0.4,
    );
    canvas.drawOval(faceRect, faceOpeningPaint);

    // Eyes (two small dots peeking through)
    /*final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final leftEye = Offset(center.dx - 12, center.dy);
    final rightEye = Offset(center.dx + 12, center.dy);

    canvas.drawCircle(leftEye, 4, eyePaint);
    canvas.drawCircle(rightEye, 4, eyePaint);

    // Pupils
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(leftEye, 2, pupilPaint);
    canvas.drawCircle(rightEye, 2, pupilPaint);

    // Hood string ties
    final stringPaint = Paint()
      ..color = const Color(0xFFCC5500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Left string
    final leftString = Path();
    leftString.moveTo(center.dx - 20, center.dy + hoodRadius - 10);
    leftString.lineTo(center.dx - 25, center.dy + hoodRadius + 15);
    canvas.drawPath(leftString, stringPaint);

    // Right string
    final rightString = Path();
    rightString.moveTo(center.dx + 20, center.dy + hoodRadius - 10);
    rightString.lineTo(center.dx + 25, center.dy + hoodRadius + 15);
    canvas.drawPath(rightString, stringPaint);*/
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
