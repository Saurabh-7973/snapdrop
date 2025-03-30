import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FloatingSquares extends StatefulWidget {
  const FloatingSquares({super.key});

  @override
  State<FloatingSquares> createState() => _FloatingSquaresState();
}

class _FloatingSquaresState extends State<FloatingSquares>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<Square> squares = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
    _generateSquares();
  }

  void _generateSquares() {
    Random random = Random();
    for (int i = 0; i < 40; i++) {
      squares.add(
        Square(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 10 + 4,
          speed: random.nextDouble() * 0.0005 + 0.0002,
          direction: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: squares.map((square) => _buildSquare(square)).toList(),
    );
  }

  Widget _buildSquare(Square square) {
    square.move();

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      top: square.y * MediaQuery.of(context).size.height,
      left: square.x * MediaQuery.of(context).size.width,
      child: Transform.rotate(
        angle: square.rotation,
        child: AnimatedOpacity(
          duration: const Duration(seconds: 3),
          opacity: square.opacity,
          child: Container(
            height: square.size,
            width: square.size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.03),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Square {
  double x;
  double y;
  double size;
  double speed;
  double direction;
  double rotation;
  double opacity;

  Square({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.direction,
  })  : rotation = Random().nextDouble() * 2 * pi,
        opacity = Random().nextDouble() * 0.4 + 0.1;

  void move() {
    x += cos(direction) * speed;
    y += sin(direction) * speed;

    // Prevent clustering in the middle
    if (x < 0.05 || x > 0.95 || y < 0.05 || y > 0.95) {
      direction = Random().nextDouble() * 2 * pi;
    }

    // Reset position when fully out of bounds
    if (x > 1.1 || x < -0.1 || y > 1.1 || y < -0.1) {
      x = Random().nextDouble();
      y = Random().nextDouble();
      direction = Random().nextDouble() * 2 * pi;
    }
  }
}
