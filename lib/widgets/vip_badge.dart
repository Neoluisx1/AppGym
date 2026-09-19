import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';

/// Chip dorado para señalar estado premium (membresía VIP, tier alto).
/// Uso restringido: solo en pantallas con semántica realmente premium.
class VipBadge extends StatelessWidget {
  final String label;
  final double fontSize;

  /// Si es true, solo muestra el ícono de corona (para espacios muy ajustados).
  final bool compact;

  const VipBadge({
    super.key,
    this.label = 'VIP',
    this.fontSize = 11,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.vipGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.crown, size: fontSize, color: Colors.white),
          if (!compact) ...[
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
