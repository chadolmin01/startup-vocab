import 'dart:math';
import 'package:flutter/material.dart';

/// A subtle animated star field background with twinkling stars
/// and occasional shooting stars. Designed for dark backgrounds.
class StarField extends StatefulWidget {
  final Widget child;
  final int starCount;
  final bool showShootingStars;

  const StarField({
    super.key,
    required this.child,
    this.starCount = 60,
    this.showShootingStars = true,
  });

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with TickerProviderStateMixin, RouteAware {
  late final AnimationController _twinkleController;
  late final AnimationController _shootingStarController;
  final _random = Random();
  late List<_Star> _stars;
  _ShootingStar? _shootingStar;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shootingStarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _stars = List.generate(widget.starCount, (_) => _Star.random(_random));

    if (widget.showShootingStars) {
      _scheduleShootingStar();
    }
  }

  void _scheduleShootingStar() {
    final delay = Duration(seconds: 4 + _random.nextInt(8));
    Future.delayed(delay, () {
      if (!mounted || !_visible) return;
      _triggerShootingStar();
      _scheduleShootingStar();
    });
  }

  void _triggerShootingStar() {
    _shootingStar = _ShootingStar.random(_random);
    _shootingStarController
      ..reset()
      ..forward();
  }

  /// Pause animations when not visible (e.g., behind another IndexedStack tab)
  void pause() {
    if (!_visible) return;
    _visible = false;
    _twinkleController.stop();
    _shootingStarController.stop();
  }

  /// Resume animations
  void resume() {
    if (_visible) return;
    _visible = true;
    _twinkleController.repeat();
    if (widget.showShootingStars) {
      _scheduleShootingStar();
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    _shootingStarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _twinkleController,
              _shootingStarController,
            ]),
            builder: (context, _) {
              return CustomPaint(
                painter: _StarFieldPainter(
                  stars: _stars,
                  twinklePhase: _twinkleController.value,
                  shootingStar: _shootingStar,
                  shootingProgress: _shootingStarController.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x; // 0..1
  final double y; // 0..1
  final double size;
  final double brightness; // base brightness 0..1
  final double twinkleSpeed; // phase offset
  final Color color;

  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.brightness,
    required this.twinkleSpeed,
    required this.color,
  });

  factory _Star.random(Random rng) {
    final colorRoll = rng.nextDouble();
    Color color;
    if (colorRoll < 0.7) {
      color = const Color(0xFFFFFFFF);
    } else if (colorRoll < 0.85) {
      color = const Color(0xFFB0C4FF);
    } else {
      color = const Color(0xFFFFE4C4);
    }

    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 0.5 + rng.nextDouble() * 1.5,
      brightness: 0.2 + rng.nextDouble() * 0.6,
      twinkleSpeed: rng.nextDouble(),
      color: color,
    );
  }
}

class _ShootingStar {
  final double startX;
  final double startY;
  final double angle;
  final double length;

  const _ShootingStar({
    required this.startX,
    required this.startY,
    required this.angle,
    required this.length,
  });

  factory _ShootingStar.random(Random rng) {
    return _ShootingStar(
      startX: 0.2 + rng.nextDouble() * 0.6,
      startY: rng.nextDouble() * 0.4,
      angle: pi / 6 + rng.nextDouble() * pi / 4,
      length: 0.15 + rng.nextDouble() * 0.2,
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinklePhase;
  final _ShootingStar? shootingStar;
  final double shootingProgress;

  _StarFieldPainter({
    required this.stars,
    required this.twinklePhase,
    this.shootingStar,
    required this.shootingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = sin((twinklePhase + star.twinkleSpeed) * pi * 2);
      final alpha = (star.brightness + twinkle * 0.25).clamp(0.05, 0.85);

      final paint = Paint()
        ..color = star.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }

    if (shootingStar != null && shootingProgress > 0 && shootingProgress < 1) {
      _drawShootingStar(canvas, size, shootingStar!, shootingProgress);
    }
  }

  void _drawShootingStar(
    Canvas canvas,
    Size size,
    _ShootingStar ss,
    double progress,
  ) {
    final startX = ss.startX * size.width;
    final startY = ss.startY * size.height;
    final dx = cos(ss.angle) * ss.length * size.width;
    final dy = sin(ss.angle) * ss.length * size.height;

    final headT = progress;
    final tailT = (progress - 0.4).clamp(0.0, 1.0);

    final headX = startX + dx * headT;
    final headY = startY + dy * headT;
    final tailX = startX + dx * tailT;
    final tailY = startY + dy * tailT;

    final alpha = progress < 0.2
        ? progress / 0.2
        : progress > 0.7
            ? (1.0 - progress) / 0.3
            : 1.0;

    final gradient = LinearGradient(
      colors: [
        const Color(0x00FFFFFF),
        Color.fromRGBO(255, 255, 255, 0.8 * alpha),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromPoints(Offset(tailX, tailY), Offset(headX, headY)),
      )
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(tailX, tailY), Offset(headX, headY), paint);

    final headPaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(headX, headY), 2.0, headPaint);
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) =>
      twinklePhase != oldDelegate.twinklePhase ||
      shootingProgress != oldDelegate.shootingProgress;
}
