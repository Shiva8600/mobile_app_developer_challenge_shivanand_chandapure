import 'package:flutter/material.dart';

import '../theme/peblo_palette.dart';

class BuddyHero extends StatelessWidget {
  const BuddyHero({
    super.key,
    required this.isHappy,
    required this.isListening,
  });

  final bool isHappy;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pip the robot story buddy',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        height: isHappy ? 142 : 132,
        width: isHappy ? 142 : 132,
        decoration: BoxDecoration(
          color: isHappy ? PebloPalette.yellow : PebloPalette.sky,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: PebloPalette.ink, width: 3),
          boxShadow: const [
            BoxShadow(
              blurRadius: 0,
              offset: Offset(0, 6),
              color: PebloPalette.ink,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _BuddyPainter(isHappy: isHappy, isListening: isListening),
        ),
      ),
    );
  }
}

class _BuddyPainter extends CustomPainter {
  const _BuddyPainter({required this.isHappy, required this.isListening});

  final bool isHappy;
  final bool isListening;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = PebloPalette.paper;
    final facePaint = Paint()..color = PebloPalette.ink;
    final cheekPaint = Paint()..color = PebloPalette.coral;
    final antennaPaint = Paint()
      ..color = PebloPalette.ink
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final outlinePaint = Paint()
      ..color = PebloPalette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final center = Offset(size.width / 2, size.height / 2);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * .66,
        height: size.height * .58,
      ),
      Radius.circular(size.width * .18),
    );

    canvas.drawLine(
      Offset(center.dx, size.height * .2),
      Offset(center.dx, size.height * .08),
      antennaPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, size.height * .07),
      size.width * .045,
      facePaint,
    );
    canvas.drawRRect(body, bodyPaint);
    canvas.drawRRect(body, outlinePaint);

    final eyeY = size.height * .45;
    canvas.drawCircle(
      Offset(size.width * .4, eyeY),
      size.width * .042,
      facePaint,
    );
    canvas.drawCircle(
      Offset(size.width * .6, eyeY),
      size.width * .042,
      facePaint,
    );
    canvas.drawCircle(
      Offset(size.width * .34, size.height * .55),
      size.width * .035,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .66, size.height * .55),
      size.width * .035,
      cheekPaint,
    );

    final mouth = Path();
    if (isHappy) {
      mouth.moveTo(size.width * .42, size.height * .58);
      mouth.quadraticBezierTo(
        center.dx,
        size.height * .72,
        size.width * .58,
        size.height * .58,
      );
    } else {
      mouth.moveTo(size.width * .43, size.height * .63);
      mouth.quadraticBezierTo(
        center.dx,
        isListening ? size.height * .7 : size.height * .61,
        size.width * .57,
        size.height * .63,
      );
    }

    canvas.drawPath(
      mouth,
      Paint()
        ..color = facePaint.color
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter oldDelegate) {
    return oldDelegate.isHappy != isHappy ||
        oldDelegate.isListening != isListening;
  }
}
