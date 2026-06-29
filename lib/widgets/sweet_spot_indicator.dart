import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/theme.dart';

class SweetSpotIndicator extends StatelessWidget {
  final double ratio;
  final double size;

  const SweetSpotIndicator({
    super.key,
    required this.ratio,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (ratio > 1.0) {
      return Icon(
        Icons.local_fire_department,
        color: AppColors.success,
        size: size * 0.83,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(ratio: ratio),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;

  _RingPainter({required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    if (ratio > 0) {
      final fgPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final sweep = 2 * pi * ratio.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweep,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}
