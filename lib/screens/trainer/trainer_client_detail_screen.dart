import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/trainer_provider.dart';
import '../../models/trainer_model.dart';
import 'trainer_evaluation_form_screen.dart';
import 'trainer_goal_form_screen.dart';
import 'trainer_progress_form_screen.dart';
import 'trainer_routines_screen.dart';
import 'trainer_nutrition_screen.dart';
import 'trainer_chat_list_screen.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  final int clientId;
  const TrainerClientDetailScreen({super.key, required this.clientId});

  @override
  State<TrainerClientDetailScreen> createState() => _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerProvider>().fetchClientDetail(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerProvider>();
    final client   = provider.selectedClient;

    if (provider.loadingDetail) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Cliente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Cliente')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text('No se pudo cargar el cliente'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<TrainerProvider>().fetchClientDetail(widget.clientId),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Banner header ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF0D2137)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30, top: -30,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 20, right: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
                          backgroundImage: client.photo != null ? NetworkImage(client.photo!) : null,
                          child: client.photo == null
                              ? Text(
                                  client.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (client.membership != null)
                                _membershipBadge(client.membership!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Action buttons
                _buildActionButtons(context, client),
                const SizedBox(height: AppTheme.spacing20),

                // Stats row
                Row(
                  children: [
                    Expanded(child: _buildStatTile(context, '${client.stats.totalAttendances}', 'Asistencias\ntotales', Icons.fitness_center_rounded, AppTheme.primaryOrange)),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(child: _buildStatTile(context, '${client.stats.monthAttendances}', 'Este\nmes', Icons.calendar_month_rounded, AppTheme.infoColor)),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(child: _buildStatTile(context, '${client.stats.activeRoutines}', 'Rutinas\nactivas', Icons.list_alt_rounded, AppTheme.successColor)),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(child: _buildStatTile(context, '${client.points}', 'Puntos', Icons.stars_rounded, AppTheme.warningColor)),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: AppTheme.spacing20),

                // Membership card
                if (client.membership != null) ...[
                  _buildSectionLabel(context, 'Membresía'),
                  const SizedBox(height: AppTheme.spacing12),
                  _buildMembershipCard(context, client.membership!)
                      .animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppTheme.spacing20),
                ],

                // Personal info
                _buildSectionLabel(context, 'Información Personal'),
                const SizedBox(height: AppTheme.spacing12),
                _buildInfoGrid(context, client)
                    .animate().fadeIn(delay: 150.ms),

                const SizedBox(height: AppTheme.spacing20),

                // Recent attendances
                _buildSectionLabel(context, 'Últimas Asistencias'),
                const SizedBox(height: AppTheme.spacing12),
                _buildAttendances(context, client.recentAttendances)
                    .animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppTheme.spacing32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, TrainerClientDetailModel client) {
    final actions = [
      _ActionBtn(Icons.monitor_weight_outlined, 'Evaluar', AppTheme.infoColor, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerEvaluationFormScreen(clientId: client.id, clientName: client.name),
        ));
      }),
      _ActionBtn(Icons.flag_outlined, 'Meta', AppTheme.primaryOrange, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerGoalFormScreen(clientId: client.id, clientName: client.name),
        ));
      }),
      _ActionBtn(Icons.straighten_outlined, 'Medidas', AppTheme.successColor, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerProgressFormScreen(clientId: client.id, clientName: client.name),
        ));
      }),
      _ActionBtn(Icons.list_alt_rounded, 'Rutinas', AppTheme.warningColor, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerRoutinesScreen(clientId: client.id, clientName: client.name),
        ));
      }),
      _ActionBtn(Icons.restaurant_menu_rounded, 'Nutrición', AppTheme.successColor, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerNutritionScreen(clientId: client.id, clientName: client.name),
        ));
      }),
      _ActionBtn(Icons.chat_bubble_outline_rounded, 'Chat', AppTheme.infoColor, () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TrainerChatScreen(
            clientUserId: client.userId,
            clientName: client.name,
          ),
        ));
      }),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: GestureDetector(
          onTap: a.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: a.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(a.icon, color: a.color, size: 24),
                const SizedBox(height: 4),
                Text(
                  a.label,
                  style: TextStyle(color: a.color, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    ).animate().fadeIn(duration: 350.ms);
  }

  // ── Membership badge ─────────────────────────────────────────────────────────
  Widget _membershipBadge(ClientMembershipDetail m) {
    final color = m.isActive ? AppTheme.successColor : AppTheme.errorColor;
    final label = m.isActive
        ? (m.daysRemaining != null ? '${m.daysRemaining} días restantes' : 'Activa')
        : 'Vencida';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ── Stat tile ────────────────────────────────────────────────────────────────
  Widget _buildStatTile(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: context.borderCol),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: context.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2),
        ],
      ),
    );
  }

  // ── Membership card ──────────────────────────────────────────────────────────
  Widget _buildMembershipCard(BuildContext context, ClientMembershipDetail m) {
    final color = m.isActive ? AppTheme.successColor : AppTheme.errorColor;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(Icons.card_membership_rounded, color: color, size: 22),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (m.startDate != null)
                  Text('${m.startDate} → ${m.endDate ?? '?'}', style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              m.isActive ? 'ACTIVA' : 'VENCIDA',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info grid ────────────────────────────────────────────────────────────────
  Widget _buildInfoGrid(BuildContext context, TrainerClientDetailModel client) {
    final items = <_InfoItem>[
      if (client.document != null) _InfoItem(Icons.badge_outlined, 'Documento', client.document!, AppTheme.infoColor),
      if (client.email != null) _InfoItem(Icons.email_outlined, 'Correo', client.email!, AppTheme.infoColor),
      if (client.phone != null) _InfoItem(Icons.phone_outlined, 'Teléfono', client.phone!, AppTheme.successColor),
      if (client.dateOfBirth != null) _InfoItem(Icons.cake_outlined, 'Nacimiento', client.dateOfBirth!, AppTheme.warningColor),
      if (client.gender != null) _InfoItem(Icons.person_outline, 'Género', client.gender!, AppTheme.primaryOrange),
      if (client.address != null) _InfoItem(Icons.location_on_outlined, 'Dirección', client.address!, context.textSecondCol),
      if (client.emergencyContact != null) _InfoItem(Icons.emergency_outlined, 'Emergencia', '${client.emergencyContact} ${client.emergencyPhone ?? ''}', AppTheme.errorColor),
    ];

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Text('Sin información adicional', style: context.textTheme.bodyMedium),
      );
    }

    return Column(
      children: items.map((item) => Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
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
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: context.textTheme.bodySmall),
                  Text(item.value, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ── Attendances list ─────────────────────────────────────────────────────────
  Widget _buildAttendances(BuildContext context, List<AttendanceEntry> attendances) {
    if (attendances.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Row(
          children: [
            Icon(Icons.event_busy_outlined, color: context.textTertCol),
            const SizedBox(width: 12),
            Text('Sin asistencias registradas', style: context.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Column(
      children: attendances.map((a) => Container(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryOrange, size: 18),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(a.checkIn),
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (a.duration != null)
                    Text('Duración: ${a.duration}', style: context.textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                a.checkOut != null ? 'Completa' : 'Sin salida',
                style: TextStyle(
                  color: a.checkOut != null ? AppTheme.successColor : AppTheme.warningColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: context.textTheme.headlineSmall),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return 'Sin fecha';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _InfoItem(this.icon, this.label, this.value, this.color);
}

class _ActionBtn {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _ActionBtn(this.icon, this.label, this.color, this.onTap);
}
