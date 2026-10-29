import 'package:flutter/material.dart';

/// Custom-painted vector soda can icon used on marked dates in the Soda Calendar
/// and in brand badges.
class SodaCanLogoIcon extends StatelessWidget {
  const SodaCanLogoIcon({
    super.key,
    required this.color,
    this.size = 18,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: _CanLogoPainter(color: color),
      ),
    );
  }
}

class _CanLogoPainter extends CustomPainter {
  const _CanLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Can body rounded rectangle
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.68, h * 0.78),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(body, fillPaint);
    canvas.drawRRect(body, strokePaint);

    // Top lid rim
    canvas.drawLine(
      Offset(w * 0.25, h * 0.14),
      Offset(w * 0.75, h * 0.14),
      strokePaint,
    );

    // Pop-tab ring on top
    canvas.drawLine(
      Offset(w * 0.36, h * 0.05),
      Offset(w * 0.64, h * 0.05),
      strokePaint,
    );

    // Specular wave stripe across the middle of the can
    final Path wave = Path()
      ..moveTo(w * 0.24, h * 0.52)
      ..quadraticBezierTo(w * 0.40, h * 0.42, w * 0.52, h * 0.52)
      ..quadraticBezierTo(w * 0.64, h * 0.62, w * 0.76, h * 0.52);
    canvas.drawPath(
      wave,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CanLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
