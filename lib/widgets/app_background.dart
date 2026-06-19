import 'package:flutter/material.dart';

/// Canonical app background — the single source of truth for the dark-green
/// identity. Every screen wraps its content in this widget so the background
/// is byte-for-byte identical app-wide (fixes per-screen background drift).
///
/// Layers, bottom to top:
///   1. base fill #142C1D
///   2. primary green glow, upper-left
///   3. subtle teal cast, lower-left
///   4. transparent -> black vertical fade
///   5. child (screen content)
///
/// Colors are exact and locked. The only value intended to be nudged is the
/// glow center in layer 2, to align the bright corner with the Figma frame.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF142C1D), // 1 · base
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 2 · primary green glow — upper-left (colors are exact; tune only the center)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.55),
                radius: 1.15,
                colors: [Color(0xFF2C9967), Color(0x00142C1D)],
                stops: [0.0, 0.72],
              ),
            ),
          ),
          // 3 · subtle teal cast — lower-left (optional)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.85, 0.55),
                radius: 0.9,
                colors: [Color(0x66208071), Color(0x00142C1D)],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          // 4 · transparent → black vertical fade
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xFF000000)],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
