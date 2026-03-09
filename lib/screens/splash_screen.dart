import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/star_field.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _meteorController;
  late final AnimationController _revealController;
  late final AnimationController _textController;
  late final AnimationController _fadeController;

  late final Animation<double> _meteorProgress;
  late final Animation<double> _revealRadius;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Phase 1: Meteor flies to center (0-800ms)
    _meteorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _meteorProgress = CurvedAnimation(
      parent: _meteorController,
      curve: Curves.easeInQuad,
    );

    // Phase 2: Circular reveal expands from impact point (logo + ring)
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Circle expands from 0 to full
    _revealRadius = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic,
      ),
    );
    // Ring flashes then fades
    _ringOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 80),
    ]).animate(_revealController);
    // Logo scales up with bounce
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Phase 3: Text slides in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Phase 4: Fade out
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _meteorController.forward();

    // Meteor arrives → circular reveal starts
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    _revealController.forward();

    // Text appears after logo settles
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textController.forward();

    // Hold for viewing
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _meteorController.dispose();
    _revealController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeController.value,
            child: child,
          );
        },
        child: StarField(
          starCount: 80,
          showShootingStars: false,
          child: Stack(
            children: [
              // Meteor streak + impact ring
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _meteorController,
                    _revealController,
                  ]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _MeteorImpactPainter(
                        meteorProgress: _meteorProgress.value,
                        revealRadius: _revealRadius.value,
                        ringOpacity: _ringOpacity.value,
                      ),
                    );
                  },
                ),
              ),
              // Logo + text — revealed by circular clip
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with circular reveal
                    AnimatedBuilder(
                      animation: _revealController,
                      builder: (context, child) {
                        return ClipOval(
                          clipper: _CircleRevealClipper(
                            fraction: _revealRadius.value,
                            maxRadius: 60,
                          ),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                          color: AppColors.accent.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          size: 40,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    // Title
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, _) {
                        return Opacity(
                          opacity: _textOpacity.value,
                          child: SlideTransition(
                            position: _textSlide,
                            child: Column(
                              children: [
                                const Text(
                                  'STARTUP BITE',
                                  style: AppTextStyles.h1,
                                ),
                                const SizedBox(height: Spacing.sm),
                                Text(
                                  'ODYSSEY VENTURES',
                                  style: AppTextStyles.labelColored(
                                    AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular clipper that reveals content from center outward
class _CircleRevealClipper extends CustomClipper<Rect> {
  final double fraction; // 0..1
  final double maxRadius;

  _CircleRevealClipper({required this.fraction, required this.maxRadius});

  @override
  Rect getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = maxRadius * fraction;
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      fraction != oldClipper.fraction;
}

/// Paints meteor trail + circular impact ring/shockwave
class _MeteorImpactPainter extends CustomPainter {
  final double meteorProgress;
  final double revealRadius;
  final double ringOpacity;

  _MeteorImpactPainter({
    required this.meteorProgress,
    required this.revealRadius,
    required this.ringOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // === Meteor trail ===
    if (meteorProgress > 0 && meteorProgress < 0.98) {
      final startX = size.width * 0.85;
      final startY = size.height * 0.08;

      final headT = meteorProgress;
      final tailT = (meteorProgress - 0.45).clamp(0.0, 1.0);

      final headX = startX + (cx - startX) * headT;
      final headY = startY + (cy - startY) * headT;
      final tailX = startX + (cx - startX) * tailT;
      final tailY = startY + (cy - startY) * tailT;

      // Fade trail as it approaches center
      final trailAlpha = (1.0 - (meteorProgress - 0.6).clamp(0.0, 1.0) * 2.5);

      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FFFFFF),
            Color.fromRGBO(96, 165, 250, 0.9 * trailAlpha),
            Color.fromRGBO(255, 255, 255, 0.95 * trailAlpha),
          ],
        ).createShader(
          Rect.fromPoints(Offset(tailX, tailY), Offset(headX, headY)),
        )
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(tailX, tailY),
        Offset(headX, headY),
        trailPaint,
      );

      // Bright head
      final headPaint = Paint()
        ..color = Color.fromRGBO(255, 255, 255, 0.9 * trailAlpha);
      canvas.drawCircle(Offset(headX, headY), 3.0, headPaint);
    }

    // === Impact ring / shockwave ===
    if (ringOpacity > 0) {
      final ringRadius = 40 + 120 * revealRadius;

      // Outer ring
      final ringPaint = Paint()
        ..color = Color.fromRGBO(96, 165, 250, ringOpacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), ringRadius, ringPaint);

      // Inner glow
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.fromRGBO(96, 165, 250, ringOpacity * 0.25),
            Color.fromRGBO(96, 165, 250, ringOpacity * 0.08),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: ringRadius),
        );
      canvas.drawCircle(Offset(cx, cy), ringRadius, glowPaint);

      // Scatter particles along the ring
      if (revealRadius > 0.05 && revealRadius < 0.8) {
        final particleAlpha = ringOpacity * 0.8;
        final particlePaint = Paint()
          ..color = Color.fromRGBO(255, 255, 255, particleAlpha)
          ..style = PaintingStyle.fill;

        final particleCount = 8;
        for (int i = 0; i < particleCount; i++) {
          final angle = (i / particleCount) * 2 * pi + revealRadius * pi;
          final r = ringRadius * (0.85 + 0.15 * sin(i * 1.7));
          final px = cx + r * cos(angle);
          final py = cy + r * sin(angle);
          canvas.drawCircle(Offset(px, py), 1.2, particlePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_MeteorImpactPainter old) =>
      meteorProgress != old.meteorProgress ||
      revealRadius != old.revealRadius ||
      ringOpacity != old.ringOpacity;
}
