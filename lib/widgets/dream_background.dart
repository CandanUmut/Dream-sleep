import 'dart:math';

import 'package:flutter/material.dart';

class DreamBackground extends StatelessWidget {
  const DreamBackground({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF050316),
            Color(0xFF110D2F),
            Color(0xFF1D1242),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const _AuroraGlow(),
          if (useSafeArea)
            SafeArea(child: content)
          else
            content,
        ],
      ),
    );
  }
}

class _AuroraGlow extends StatelessWidget {
  const _AuroraGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: _AuroraPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        colors: [
          Color(0x447B5CD6),
          Color(0x11000000),
        ],
        radius: 0.6,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.15),
        radius: size.shortestSide * 0.7,
      ));
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), size.shortestSide * 0.7, paint);

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        colors: [
          Color(0x334AD8E8),
          Color(0x00000000),
        ],
        radius: 0.7,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.1),
        radius: size.shortestSide * 0.6,
      ));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), size.shortestSide * 0.6, paint2);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.18);
    final random = Random(7);
    for (var i = 0; i < 80; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.4;
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
