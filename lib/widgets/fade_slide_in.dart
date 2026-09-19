import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Envuelve la convención de entrada ya usada en la app
/// (`.animate().fadeIn().slideY()` con delay escalonado) en un solo widget,
/// para no repetir el mismo chain en cada pantalla.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.beginY = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(delay: delay, duration: duration)
        .slideY(begin: beginY, end: 0, delay: delay, duration: duration);
  }
}
