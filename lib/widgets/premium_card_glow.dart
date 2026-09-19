import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Envuelve UNA tarjeta destacada por pantalla (membresía activa, plan VIP)
/// con un glow dorado sutil + borde. No usar para repintar pantallas enteras.
class PremiumCardGlow extends StatelessWidget {
  final Widget child;
  final double radius;

  const PremiumCardGlow({
    super.key,
    required this.child,
    this.radius = AppTheme.radiusLarge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1.2),
        boxShadow: AppTheme.goldGlowShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
