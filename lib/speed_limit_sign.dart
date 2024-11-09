import 'package:flutter/material.dart';

class SpeedLimitPainter extends CustomPainter {
  final String speedLimit; // Speed limit to display

  SpeedLimitPainter(this.speedLimit);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the red circle
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0; // Thickness of the circle's boundary

    // Draw the circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7; // Adjust radius with padding
    canvas.drawCircle(center, radius, paint);

    // Draw the speed limit number inside the circle
    final textPainter = TextPainter(

      text: TextSpan(

        text: speedLimit,
        style: TextStyle(
          fontSize: size.width * 0.4, // Make the text responsive to size
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Center the text inside the circle
    final offset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SpeedLimitSign extends StatelessWidget {
  final String speedLimit;

  SpeedLimitSign({required this.speedLimit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Adjust size as needed
      height: 150,
      child: CustomPaint(
        painter: SpeedLimitPainter(speedLimit),
      ),
    );
  }
}