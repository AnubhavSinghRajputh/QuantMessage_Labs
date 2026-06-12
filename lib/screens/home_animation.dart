import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeAnimation extends StatefulWidget {
  const HomeAnimation({super.key});

  @override
  State<HomeAnimation> createState() => _HomeAnimationState();
}

class _HomeAnimationState extends State<HomeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  late List<Planet> _planets;
  late List<Nebula> _nebulae;

  @override
  void initState() {
    super.initState();

    // Slow, cinematic animation cycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _initSpaceObjects();
  }

  void _initSpaceObjects() {
    final random = math.Random();

    // 1. Chromatic Stars: Different sizes and colors for a realistic galaxy
    _stars = List.generate(200, (index) {
      final colors = [Colors.white, Colors.blueAccent, Colors.yellowAccent, Colors.purpleAccent];
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 1.8 + 0.4,
        phase: random.nextDouble() * math.pi * 2,
        speed: random.nextDouble() * 0.05 + 0.02,
        color: colors[random.nextInt(colors.length)],
      );
    });

    // 2. Orbiting Planets with atmospheric glows
    _planets = [
      Planet(
        radius: 22,
        orbitRadius: 140,
        speed: 0.15,
        color: const Color(0xFF4D96FF), // Soft Blue
        glowColor: Colors.blue.withOpacity(0.2),
        phase: 0.0,
      ),
      Planet(
        radius: 12,
        orbitRadius: 220,
        speed: -0.1,
        color: const Color(0xFFF94144), // Martian Red
        glowColor: Colors.red.withOpacity(0.2),
        phase: math.pi,
      ),
      Planet(
        radius: 8,
        orbitRadius: 300,
        speed: 0.08,
        color: const Color(0xFF90BDFE), // Ice Blue
        glowColor: Colors.cyan.withOpacity(0.2),
        phase: math.pi / 2,
      ),
    ];

    // 3. Nebulae: Large, soft, drifting clouds of gas
    _nebulae = List.generate(4, (index) {
      return Nebula(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: random.nextDouble() * 200 + 150,
        color: [
          Colors.deepPurple.withOpacity(0.05),
          Colors.blue.withOpacity(0.05),
          Colors.indigo.withOpacity(0.05),
        ][random.nextInt(3)],
        speed: random.nextDouble() * 0.02,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF020205),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: SpacePainter(
                  animationValue: _controller.value,
                  stars: _stars,
                  planets: _planets,
                  nebulae: _nebulae,
                ),
                child: Container(),
              );
            },
          ),
        );
      },
    );
  }
}

// --- DATA MODELS ---

class Star {
  final double x, y, size, phase, speed;
  final Color color;
  Star({required this.x, required this.y, required this.size, required this.phase, required this.speed, required this.color});
}

class Planet {
  final double radius, orbitRadius, speed, phase;
  final Color color, glowColor;
  Planet({required this.radius, required this.orbitRadius, required this.speed, required this.color, required this.glowColor, required this.phase});
}

class Nebula {
  final double x, y, radius, speed;
  final Color color;
  Nebula({required this.x, required this.y, required this.radius, required this.speed, required this.color});
}

// --- THE PAINTER ---

class SpacePainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;
  final List<Planet> planets;
  final List<Nebula> nebulae;

  SpacePainter({required this.animationValue, required this.stars, required this.planets, required this.nebulae});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. BACKGROUND GRADIENT
    final paintBg = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF111122), const Color(0xFF05050A), const Color(0xFF020205)],
        center: Alignment.center,
        radius: 1.5,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    // 2. DRAW NEBULAE (Slow drifting clouds)
    for (final nebula in nebulae) {
      final driftX = math.sin(animationValue * 2 * math.pi * nebula.speed) * 50;
      final driftY = math.cos(animationValue * 2 * math.pi * nebula.speed) * 50;

      final nebulaPaint = Paint()
        ..color = nebula.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

      canvas.drawCircle(Offset(nebula.x * size.width + driftX, nebula.y * size.height + driftY), nebula.radius, nebulaPaint);
    }

    // 3. DRAW THE MOON (3D Spherical Effect)
    // Outer Atmosphere Glow
    final moonGlow = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, 45, moonGlow);

    // Moon Body with 3D Gradient
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey.shade300, Colors.grey.shade700],
        center: const Alignment(-0.3, -0.3), // Light source from top-left
        radius: 0.7,
      ).createShader(Rect.fromCircle(center: center, radius: 30));
    canvas.drawCircle(center, 30, moonPaint);

    // 4. DRAW STARS (Chromatic Twinkling)
    for (final star in stars) {
      final opacity = (0.3 + 0.7 * math.sin(animationValue * 2 * math.pi * star.speed + star.phase)).clamp(0.1, 1.0);
      final starPaint = Paint()..color = star.color.withOpacity(opacity);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, starPaint);
    }

    // 5. DRAW PLANETS (Orbiting 3D Spheres)
    for (final planet in planets) {
      final angle = (animationValue * 2 * math.pi * planet.speed) + planet.phase;
      final px = center.dx + math.cos(angle) * planet.orbitRadius;
      final py = center.dy + math.sin(angle) * planet.orbitRadius;

      // Atmosphere Glow
      final glowPaint = Paint()
        ..color = planet.glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(px, py), planet.radius * 2.2, glowPaint);

      // Planet Body with 3D Lighting
      final planetPaint = Paint()
        ..shader = RadialGradient(
          colors: [planet.color, Colors.black],
          center: const Alignment(-0.3, -0.3), // Light source from top-left
          stops: const [0.2, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: planet.radius));

      canvas.drawCircle(Offset(px, py), planet.radius, planetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => true;
}
