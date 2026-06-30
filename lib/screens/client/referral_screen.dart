import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../providers/referral_provider.dart';
import '../../models/referral_model.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReferralProvider>().fetchReferrals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferralProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ReferralProvider>().refresh(),
          ),
        ],
      ),
      body: provider.isLoading && provider.data == null
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.data == null
              ? _buildError(provider)
              : RefreshIndicator(
                  onRefresh: () => context.read<ReferralProvider>().refresh(),
                  child: _buildContent(provider.data!),
                ),
    );
  }

  Widget _buildContent(ReferralModel data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code card
          _buildCodeCard(data)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms),

          const SizedBox(height: AppTheme.spacing20),

          // Stats
          _buildStats(data.stats)
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: AppTheme.spacing24),

          // How it works
          _buildHowItWorks(data.pointsPerReferral)
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),

          const SizedBox(height: AppTheme.spacing24),

          // Referred clients
          _buildReferredList(data.referredClients)
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms),

          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }

  // ── Code card ─────────────────────────────────────────────────────────────────
  Widget _buildCodeCard(ReferralModel data) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C38), Color(0xFFD4500A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -15,
            top: -15,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -25,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'TU CÓDIGO DE REFERIDO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing20),

                // Code display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.referralCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          fontFamily: 'monospace',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 22),
                        onPressed: () => _copyCode(data.referralCode),
                        tooltip: 'Copiar',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacing16),

                // Share button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareCode(data.referralCode, data.pointsPerReferral),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text(
                      'Compartir Código',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────
  Widget _buildStats(ReferralStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '${stats.totalReferrals}',
            label: 'Referidos',
            icon: Icons.group_rounded,
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildStatCard(
            value: '${stats.activeReferrals}',
            label: 'Activos',
            icon: Icons.check_circle_rounded,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildStatCard(
            value: '${stats.pointsEarned}',
            label: 'Puntos',
            icon: Icons.stars_rounded,
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  // ── How it works ──────────────────────────────────────────────────────────────
  Widget _buildHowItWorks(int pointsPerReferral) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text('¿Cómo funciona?', style: context.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildStep(
            step: '1',
            text: 'Comparte tu código con amigos o familiares',
            icon: Icons.share_rounded,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildStep(
            step: '2',
            text: 'Tu amigo se registra en el gimnasio usando tu código',
            icon: Icons.person_add_rounded,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildStep(
            step: '3',
            text: '¡Ambos ganan $pointsPerReferral puntos cuando se active la membresía!',
            icon: Icons.stars_rounded,
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String step,
    required String text,
    required IconData icon,
    Color color = AppTheme.primaryOrange,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text, style: context.textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }

  // ── Referred clients list ─────────────────────────────────────────────────────
  Widget _buildReferredList(List<ReferredClient> clients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('Mis Referidos (${clients.length})', style: context.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppTheme.spacing12),

        if (clients.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: context.borderCol),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.textTertCol.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_outline_rounded, size: 36, color: context.textTertCol),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text('Aún no tienes referidos', style: context.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Text(
                  '¡Comparte tu código y empieza a ganar puntos!',
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...clients.map((client) => _buildClientTile(client)),
      ],
    );
  }

  Widget _buildClientTile(ReferredClient client) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Se unió el ${client.joinedAt}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: client.isActive
                  ? AppTheme.successColor.withValues(alpha: 0.15)
                  : context.textTertCol.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: client.isActive ? AppTheme.successColor : context.textTertCol,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  client.isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: client.isActive ? AppTheme.successColor : context.textTertCol,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────────
  Widget _buildError(ReferralProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: AppTheme.spacing16),
            const Text('No se pudo cargar', style: TextStyle(fontSize: 16)),
            const SizedBox(height: AppTheme.spacing16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código copiado al portapapeles'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareCode(String code, int points) {
    Share.share(
      '¡Únete al gimnasio y ambos ganamos $points puntos! 💪\n'
      'Usa mi código de referido al registrarte: $code',
      subject: 'Código de referido',
    );
  }
}
