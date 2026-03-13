import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A particle-based celebration effect (stars/confetti).
/// Shows briefly then auto-fades.
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final int particleCount;

  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.trigger,
    this.particleCount = 20,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _particles = [];
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _active = false);
      }
    });
  }

  @override
  void didUpdateWidget(CelebrationOverlay old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(_random),
    );
    _active = true;
    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CelebrationPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double startX; // 0..1
  final double startY; // 0..1
  final double dx;
  final double dy;
  final double size;
  final Color color;
  final double rotationSpeed;

  const _Particle({
    required this.startX,
    required this.startY,
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });

  factory _Particle.random(Random rng) {
    final colors = [
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      const Color(0xFFA78BFA),
      Colors.white,
    ];
    return _Particle(
      startX: 0.2 + rng.nextDouble() * 0.6,
      startY: 0.3 + rng.nextDouble() * 0.3,
      dx: (rng.nextDouble() - 0.5) * 2.0,
      dy: -1.0 - rng.nextDouble() * 1.5,
      size: 2.0 + rng.nextDouble() * 4.0,
      color: colors[rng.nextInt(colors.length)],
      rotationSpeed: rng.nextDouble() * 4.0,
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _CelebrationPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = progress < 0.7 ? 1.0 : (1.0 - progress) / 0.3;

    for (final p in particles) {
      final t = progress;
      final gravity = 0.5 * t * t;
      final x = (p.startX + p.dx * t * 0.3) * size.width;
      final y = (p.startY + p.dy * t * 0.2 + gravity * 0.4) * size.height;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.fill;

      // Draw star shape
      final path = _starPath(x, y, p.size, p.rotationSpeed * t);
      canvas.drawPath(path, paint);
    }
  }

  Path _starPath(double cx, double cy, double radius, double rotation) {
    final path = Path();
    const points = 4;
    final innerRadius = radius * 0.4;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) + rotation;
      final r = i.isEven ? radius : innerRadius;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_CelebrationPainter old) => progress != old.progress;
}
