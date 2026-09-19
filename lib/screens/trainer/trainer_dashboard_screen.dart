import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/trainer_model.dart';
import 'trainer_clients_screen.dart';
import 'trainer_client_detail_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/animated_stat_counter.dart';

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final provider  = context.watch<TrainerProvider>();
    final dashboard = provider.dashboard;
    final user      = auth.user;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.name.split(' ').first ?? 'Instructor'} 👋',
              style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE d MMM', 'es').format(DateTime.now()),
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: provider.loadingDashboard && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<TrainerProvider>().refreshDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card del instructor
                    _buildTrainerCard(context, dashboard?.trainer, user?.name)
                        .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: AppTheme.spacing20),

                    // Stats grid
                    _buildSectionHeader(context, 'Resumen'),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildStatsGrid(context, dashboard?.stats)
                        .animate().fadeIn(delay: 100.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing24),

                    // Clientes preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader(context, 'Mis Clientes'),
                        TextButton(
                          onPressed: () => _goToClients(context),
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildClientsPreview(context, dashboard?.clientsPreview ?? [])
                        .animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing32),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Trainer header card ───────────────────────────────────────────────────────
  Widget _buildTrainerCard(BuildContext context, TrainerInfo? trainer, String? name) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
            backgroundImage: trainer?.photo != null
                ? NetworkImage(trainer!.photo!)
                : null,
            child: trainer?.photo == null
                ? Text(
                    (name ?? 'I')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Instructor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trainer?.specialization ?? 'Entrenador Personal',
                    style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  // ── Stats grid 2x2 ───────────────────────────────────────────────────────────
  Widget _buildStatsGrid(BuildContext context, TrainerStats? stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacing12,
      crossAxisSpacing: AppTheme.spacing12,
      childAspectRatio: 1.55,
      children: [
        _buildStatCard(
          context,
          icon: Icons.people_rounded,
          value: stats?.totalClients ?? 0,
          label: 'Total clientes',
          color: AppTheme.infoColor,
        ),
        _buildStatCard(
          context,
          icon: Icons.check_circle_outline_rounded,
          value: stats?.activeClients ?? 0,
          label: 'Activos',
          color: AppTheme.successColor,
        ),
        _buildStatCard(
          context,
          icon: Icons.flag_rounded,
          value: stats?.pendingGoals ?? 0,
          label: 'Metas activas',
          color: AppTheme.warningColor,
        ),
        _buildStatCard(
          context,
          icon: Icons.fitness_center_rounded,
          value: stats?.todayAttendances ?? 0,
          label: 'Asistencias hoy',
          color: AppTheme.primaryOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required num value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedStatCounter(
                  value: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(label, style: context.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Clients preview ───────────────────────────────────────────────────────────
  Widget _buildClientsPreview(BuildContext context, List<TrainerClientModel> clients) {
    if (clients.isEmpty) {
      return _buildEmpty(context, Icons.people_outlined, 'No tienes clientes asignados');
    }
    return Column(
      children: clients.map((c) => _buildClientTile(context, c)).toList(),
    );
  }

  Widget _buildClientTile(BuildContext context, TrainerClientModel client) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrainerClientDetailScreen(clientId: client.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
              backgroundImage: client.photo != null ? NetworkImage(client.photo!) : null,
              child: client.photo == null
                  ? Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    client.membership ?? 'Sin membresía',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _buildStatusBadge(context, client.isActive, client.daysRemaining),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertCol),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isActive, int? daysRemaining) {
    final color = isActive ? AppTheme.successColor : AppTheme.errorColor;
    final label = isActive
        ? (daysRemaining != null ? '$daysRemaining d' : 'Activa')
        : 'Vencida';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
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
        Text(title, style: context.textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: context.textTertCol),
          const SizedBox(height: AppTheme.spacing12),
          Text(message, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  void _goToClients(BuildContext context) {
    // Navega a la pestaña de clientes en TrainerMainScreen
    final mainState = context.findAncestorStateOfType<State>();
    if (mainState != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TrainerClientsScreen()),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
