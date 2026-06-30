import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_class_provider.dart';
import '../../providers/notification_provider.dart';
import 'package:intl/intl.dart';
import 'membership_plans_screen.dart';
import 'group_classes_screen.dart';
import 'notifications_screen.dart';
import 'store_screen.dart';
import 'surveys_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
      context.read<GroupClassProvider>().fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;
    final dashboard = dashProvider.dashboard;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Consumer<DashboardProvider>(
            builder: (context, dp, _) {
              final photoUrl = dp.dashboard?.client.photoUrl;
              return photoUrl != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(photoUrl),
                      onBackgroundImageError: (_, __) {},
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
            },
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.name.split(' ').first ?? 'Usuario'} 👋',
              style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE d MMM', 'es').format(DateTime.now()),
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, np, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
                if (np.hasUnread)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        np.unreadCount > 9 ? '9+' : '${np.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: dashProvider.isLoading && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Membership card
                    (dashboard?.membership != null
                            ? _buildMembershipCard(dashboard!.membership!)
                            : _buildNoMembershipCard())
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing20),

                    // Membership expiry alert
                    if (dashboard?.membership != null &&
                        dashboard!.membership!.isActive &&
                        dashboard.membership!.daysRemaining != null &&
                        dashboard.membership!.daysRemaining! <= 5) ...[
                      _buildExpiryAlert(dashboard.membership!.daysRemaining!)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms),
                      const SizedBox(height: AppTheme.spacing12),
                    ],

                    // Banner encuestas pendientes
                    _buildSurveyBanner()
                        .animate()
                        .fadeIn(delay: 110.ms, duration: 400.ms),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.fitness_center_rounded,
                            value: '${dashboard?.stats.thisMonthAttendances ?? 0}',
                            label: 'Asistencias',
                            sublabel: 'Este mes',
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.stars_rounded,
                            value: '${dashboard?.client.points ?? 0}',
                            label: 'Puntos',
                            sublabel: 'Acumulados',
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 150.ms),

                    const SizedBox(height: AppTheme.spacing24),

                    // Quick access
                    _buildSectionHeader('Acceso Rápido'),
                    const SizedBox(height: AppTheme.spacing12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            icon: Icons.fitness_center_rounded,
                            label: 'Rutinas',
                            color: AppTheme.primaryOrange,
                            count: dashboard?.stats.activeRoutines ?? 0,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            icon: Icons.flag_rounded,
                            label: 'Metas',
                            color: AppTheme.successColor,
                            count: dashboard?.stats.activeGoals ?? 0,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing12),

                    _buildStoreCard(authProvider)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing24),

                    // Gym tour
                    _buildSectionHeader('Recorrido Virtual'),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildGymTourCard()
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing24),

                    // Group classes
                    _buildSectionHeader('Clases Grupales'),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildGroupClassesPreview()
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing24),

                    if (dashboard?.membership != null)
                      _buildMembershipActions()
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 400.ms),

                    const SizedBox(height: AppTheme.spacing32),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Membership card (premium style) ──────────────────────────────────────────
  Widget _buildMembershipCard(membership) {
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
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
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
                      child: const Icon(Icons.card_membership_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'MEMBRESÍA',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: membership.isActive
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.red.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: membership.isActive ? Colors.greenAccent : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            membership.isActive ? 'ACTIVA' : 'INACTIVA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing16),

                Text(
                  membership.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: AppTheme.spacing8),

                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      membership.daysRemaining != null
                          ? 'Vence en ${membership.daysRemaining} días'
                          : 'Membresía activa',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                if (membership.type == 'business_days' && membership.availableDays != null) ...[
                  const SizedBox(height: AppTheme.spacing16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: membership.usagePercentage,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${membership.daysUsed ?? 0} / ${membership.availableDays} días usados',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                      ),
                      Text(
                        '${(membership.availableDays ?? 0) - (membership.daysUsed ?? 0)} disponibles',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMembershipCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.textTertCol.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.card_membership_outlined, size: 40, color: context.textTertCol),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text('Sin membresía activa', style: context.textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text(
            'Contacta al gimnasio para activar tu membresía',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Expiry alert ──────────────────────────────────────────────────────────────
  Widget _buildExpiryAlert(int daysRemaining) {
    final isUrgent = daysRemaining <= 2;
    final color = isUrgent ? AppTheme.errorColor : AppTheme.warningColor;
    final String message;
    if (daysRemaining == 0) {
      message = '¡Tu membresía vence hoy!';
    } else if (daysRemaining == 1) {
      message = '¡Tu membresía vence mañana!';
    } else {
      message = '¡Tu membresía vence en $daysRemaining días!';
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MembershipPlansScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toca aquí para renovar',
                    style: TextStyle(color: color.withValues(alpha: 0.75), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ── Stat card ─────────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(sublabel, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
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

  // ── Quick access card ─────────────────────────────────────────────────────────
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '$count',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ── Gym tour card ─────────────────────────────────────────────────────────────
  Widget _buildGymTourCard() {
    return GestureDetector(
      onTap: _openGymTourVideo,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: context.surfaceColor),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 40, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    const Text(
                      'Ver Recorrido del Gimnasio',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Conoce nuestras instalaciones',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Group classes preview ─────────────────────────────────────────────────────
  Widget _buildGroupClassesPreview() {
    final classProvider = context.watch<GroupClassProvider>();
    final classes = classProvider.classes.take(3).toList();

    if (classProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (classes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        message: 'No hay clases disponibles',
      );
    }

    return Column(
      children: [
        ...classes.map((gc) => Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: context.borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppTheme.primaryOrange, size: 20),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gc.name,
                          style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: context.textTertCol),
                            const SizedBox(width: 4),
                            Text(gc.schedule, style: context.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertCol),
                ],
              ),
            )),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupClassesScreen()),
            ),
            child: const Text('Ver todas las clases'),
          ),
        ),
      ],
    );
  }

  // ── Store card ────────────────────────────────────────────────────────────────
  Widget _buildStoreCard(AuthProvider authProvider) {
    final userPoints = authProvider.user?.client?.points ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.warningColor.withValues(alpha: 0.2),
              AppTheme.warningColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.shopping_bag_rounded, color: AppTheme.warningColor, size: 28),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tienda de Recompensas',
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text('Canjea productos con tus puntos', style: context.textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppTheme.warningColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$userPoints puntos disponibles',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: context.textTertCol, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Membership actions ────────────────────────────────────────────────────────
  Widget _buildMembershipActions() {
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
          Text(
            'Gestiona tu Membresía',
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Renueva o cambia tu plan', style: context.textTheme.bodyMedium),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MembershipPlansScreen()),
              ),
              icon: const Icon(Icons.card_membership_rounded),
              label: const Text('Ver Planes de Membresía'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
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
            child: Icon(icon, size: 36, color: context.textTertCol),
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(message, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  /// Muestra un banner morado cuando hay notificaciones de encuesta sin leer.
  Widget _buildSurveyBanner() {
    final np = context.watch<NotificationProvider>();
    final surveyUnread = np.notifications.where((n) => n.type == 'survey' && !n.isRead).length;
    if (surveyUnread == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SurveysScreen()),
      ).then((_) => np.fetchNotifications()),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Tienes una encuesta pendiente!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Tu opinión es importante para nosotros',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  Future<void> _openGymTourVideo() async {
    final urlStr = AppTheme.gymTourVideoUrl.isNotEmpty
        ? AppTheme.gymTourVideoUrl
        : null;

    if (urlStr == null) {
      if (mounted) context.showErrorSnackBar('URL del video no configurada');
      return;
    }

    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      context.showErrorSnackBar('No se pudo abrir el video');
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<DashboardProvider>().refresh(),
      context.read<GroupClassProvider>().fetchClasses(),
      context.read<NotificationProvider>().refresh(),
    ]);
  }
}

