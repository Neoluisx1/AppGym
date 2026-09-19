import 'package:flutter/material.dart';

/// Cuenta desde 0 hasta [value] al construirse (sin dependencias nuevas,
/// usa TweenAnimationBuilder). Pensado para stats numéricos (puntos, KPIs).
class AnimatedStatCounter extends StatelessWidget {
  final num value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedStatCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        final text = decimals > 0
            ? animatedValue.toStringAsFixed(decimals)
            : animatedValue.round().toString();
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}
