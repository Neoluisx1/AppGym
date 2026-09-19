import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/fade_slide_in.dart';

class QrAccessScreen extends StatelessWidget {
  const QrAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final client = user?.client;
    final document = client?.document ?? '';
    final qrData = 'MEGALIFE:${user?.id ?? 0}:$document';

    return Scaffold(
      appBar: AppBar(title: const Text('QR de Acceso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          children: [
            FadeSlideIn(
              child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                border: Border.all(color: context.borderCol),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.primaryOrange, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Tu código de acceso',
                        style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF1A1A1A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing20),

                  // Name
                  Text(
                    user?.name ?? '',
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (document.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: document));
                        context.showSuccessSnackBar('CI copiado');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CI: $document',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryOrange),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              ),
            ),

            const SizedBox(height: AppTheme.spacing24),

            // Info card
            FadeSlideIn(
              delay: 150.ms,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: context.borderCol),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.info_outline, 'Muestra este QR en la recepción para registrar tu entrada al gimnasio.'),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildInfoRow(context, Icons.security, 'Este código es único y personal. No lo compartas.'),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildInfoRow(context, Icons.brightness_5_outlined, 'Aumenta el brillo de tu pantalla si el lector tiene dificultades.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryOrange),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.textTheme.bodySmall)),
      ],
    );
  }
}
