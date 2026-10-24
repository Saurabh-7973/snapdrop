import 'package:flutter/material.dart';

/// The Figma mark, drawn with CustomPaint (avoids adding an SVG dependency).
/// Five shapes in a 2:3 box — matches the logo used in the QR mockups.
class FigmaLogo extends StatelessWidget {
  final double height;
  const FigmaLogo({super.key, this.height = 18});

  @override
  Widget build(BuildContext context) {
    final w = height * 2 / 3;
    return SizedBox(
      width: w,
      height: height,
      child: CustomPaint(painter: _FigmaPainter()),
    );
  }
}

class _FigmaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 2; // unit
    final p = Paint()..isAntiAlias = true;

    // left-rounded "D" shape for a unit cell at (col, row)
    void leftPill(Color c, double col, double row) {
      p.color = c;
      final rect = Rect.fromLTWH(col * u, row * u, u, u);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(u / 2),
          bottomLeft: Radius.circular(u / 2),
        ),
        p,
      );
    }

    void rightPill(Color c, double col, double row) {
      p.color = c;
      final rect = Rect.fromLTWH(col * u, row * u, u, u);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topRight: Radius.circular(u / 2),
          bottomRight: Radius.circular(u / 2),
        ),
        p,
      );
    }

    void circle(Color c, double cx, double cy) {
      p.color = c;
      canvas.drawCircle(Offset(cx * u, cy * u), u / 2, p);
    }

    leftPill(const Color(0xFFF24E1E), 0, 0); // orange top-left
    rightPill(const Color(0xFFA259FF), 1, 0); // purple top-right
    leftPill(const Color(0xFFFF7262), 0, 1); // coral mid-left
    circle(const Color(0xFF1ABCFE), 1.5, 1.5); // blue mid-right
    circle(const Color(0xFF0ACF83), 0.5, 2.5); // green bottom-left
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
