import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'points_history_screen.dart';
import 'qr_access_screen.dart';
import 'nutrition_screen.dart';
import 'chat_screen.dart';
import 'surveys_screen.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/vip_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;
    final dashboard = dashProvider.dashboard;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photoUrl = dashboard?.client.photoUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Banner header ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient banner
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF8C38), Color(0xFFB03A00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Avatar + name at bottom of banner
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showPhotoOptions(context),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                                  boxShadow: AppTheme.subtleShadow,
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
                                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                  child: photoUrl == null
                                      ? Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primaryOrange, width: 1.5),
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.primaryOrange),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.role?.displayName ?? 'Cliente',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditDialog(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                if (user.client != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          context,
                          icon: Icons.stars_rounded,
                          value: '${user.client!.points}',
                          label: 'Puntos',
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      if (user.client!.membership != null)
                        Expanded(
                          child: _buildStatTile(
                            context,
                            icon: Icons.card_membership_rounded,
                            value: user.client!.membership!.isActive ? 'Activa' : 'Inactiva',
                            label: user.client!.membership!.name,
                            color: user.client!.membership!.isActive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            trailing: user.client!.membership!.isActive
                                ? const VipBadge(fontSize: 9, compact: true)
                                : null,
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppTheme.spacing20),
                ],

                // Info cards
                _buildSectionLabel(context, 'Información Personal'),
                const SizedBox(height: AppTheme.spacing12),

                if (user.client?.document != null)
                  _buildInfoCard(
                    context,
                    icon: Icons.badge_outlined,
                    title: 'Documento',
                    value: user.client!.document!,
                    subtitle: 'No editable',
                    color: AppTheme.infoColor,
                  ).animate().fadeIn(delay: 100.ms),

                if (user.client?.document != null) const SizedBox(height: AppTheme.spacing8),

                _buildInfoCard(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Correo',
                  value: user.email,
                  color: AppTheme.infoColor,
                ).animate().fadeIn(delay: 150.ms),

                if (user.client?.phone != null) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  _buildInfoCard(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Teléfono',
                    value: user.client!.phone!,
                    color: AppTheme.infoColor,
                  ).animate().fadeIn(delay: 200.ms),
                ],

                const SizedBox(height: AppTheme.spacing24),

                // Options
                _buildSectionLabel(context, 'Configuración'),
                const SizedBox(height: AppTheme.spacing12),

                _buildOptionCard(
                  context,
                  icon: Icons.qr_code_2_rounded,
                  title: 'QR de Acceso',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrAccessScreen()),
                  ),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Encuestas',
                  subtitle: 'Responde las encuestas del gimnasio',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SurveysScreen()),
                  ),
                ).animate().fadeIn(delay: 257.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Plan Nutricional',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NutritionScreen()),
                  ),
                ).animate().fadeIn(delay: 265.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.chat_rounded,
                  title: 'Chat con Entrenador',
                  onTap: () => _openChatWithTrainer(context),
                ).animate().fadeIn(delay: 280.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.stars_rounded,
                  title: 'Historial de puntos',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PointsHistoryScreen()),
                  ),
                ).animate().fadeIn(delay: 295.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.brightness_6_outlined,
                  title: 'Tema de la app',
                  subtitle: context.watch<ThemeProvider>().label,
                  onTap: () => _showThemeDialog(context),
                ).animate().fadeIn(delay: 310.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.policy_outlined,
                  title: 'Política de Privacidad',
                  onTap: () => launchUrl(
                    Uri.parse('https://megalifegym.com/politica-de-privacidad'),
                    mode: LaunchMode.externalApplication,
                  ),
                ).animate().fadeIn(delay: 325.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda',
                  onTap: () => _showHelpDialog(context),
                ).animate().fadeIn(delay: 340.ms),

                const SizedBox(height: AppTheme.spacing8),

                _buildOptionCard(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de',
                  onTap: () => _showAboutDialog(context),
                ).animate().fadeIn(delay: 355.ms),

                const SizedBox(height: AppTheme.spacing24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: AppTheme.spacing32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    Widget? trailing,
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
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) ...[const SizedBox(width: 6), trailing],
                  ],
                ),
                Text(label, style: context.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: context.textTheme.headlineSmall),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.bodySmall),
                Text(value, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Text(subtitle, style: context.textTheme.bodySmall?.copyWith(color: context.textTertCol)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: context.borderCol),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.textSecondCol, size: 22),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: subtitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: context.textTheme.bodyLarge),
                          Text(subtitle, style: context.textTheme.bodySmall),
                        ],
                      )
                    : Text(title, style: context.textTheme.bodyLarge),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.textTertCol),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final options = [
      (ThemeMode.dark,   Icons.dark_mode_outlined,    'Oscuro'),
      (ThemeMode.light,  Icons.light_mode_outlined,   'Claro'),
      (ThemeMode.system, Icons.brightness_auto_rounded, 'Según el teléfono'),
    ];
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tema de la app'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final (mode, icon, label) = opt;
              final selected = themeProvider.themeMode == mode;
              return ListTile(
                leading: Icon(icon, color: selected ? AppTheme.primaryOrange : null),
                title: Text(label),
                trailing: selected
                    ? const Icon(Icons.check_rounded, color: AppTheme.primaryOrange)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                onTap: () {
                  themeProvider.setTheme(mode);
                  setS(() {});
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.client?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<AuthProvider>().updateProfile(
                name: nameController.text,
                phone: phoneController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  context.showSuccessSnackBar('Perfil actualizado');
                } else {
                  context.showErrorSnackBar('Error al actualizar perfil');
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final email = AppTheme.companyEmail;
    final whatsapp = AppTheme.companyWhatsapp;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ayuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Necesitas ayuda? Contáctanos:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _helpRow(context, Icons.language_rounded, 'Web', 'megalifegym.com',
                onTap: () => launchUrl(Uri.parse('https://megalifegym.com'), mode: LaunchMode.externalApplication)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 12),
              _helpRow(context, Icons.email_outlined, 'Email', email,
                  onTap: () => launchUrl(Uri.parse('mailto:$email'))),
            ],
            if (whatsapp.isNotEmpty) ...[
              const SizedBox(height: 12),
              _helpRow(context, Icons.chat_rounded, 'WhatsApp', 'Escríbenos',
                  onTap: () => launchUrl(
                    Uri.parse('https://wa.me/${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'),
                    mode: LaunchMode.externalApplication,
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _helpRow(BuildContext context, IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryOrange),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: context.textSecondCol)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Acerca de'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.fitness_center_rounded, size: 44, color: AppTheme.primaryOrange),
            ),
            const SizedBox(height: 16),
            const Text('MegaLife Gym', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Versión 1.0.0', style: TextStyle(color: context.textSecondCol, fontSize: 13)),
            const SizedBox(height: 16),
            Text(
              'Tu gimnasio en la palma de tu mano. Controla tu asistencia, metas, rutinas y nutrición desde un solo lugar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.textSecondCol),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://megalifegym.com'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.language_rounded, size: 16),
              label: const Text('megalifegym.com'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Cerrar Sesión'),
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

  Future<void> _openChatWithTrainer(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await chatProvider.fetchTrainers();
    if (!context.mounted) return;
    Navigator.pop(context); // close loading

    if (chatProvider.trainers.isEmpty) {
      context.showErrorSnackBar('No tienes un entrenador asignado');
      return;
    }

    if (chatProvider.trainers.length == 1) {
      final t = chatProvider.trainers.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(trainerUserId: t.userIdTrainer, trainerName: t.name),
        ),
      );
      return;
    }

    // Multiple trainers — show picker
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: context.borderCol, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Selecciona un entrenador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...chatProvider.trainers.map(
              (t) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                  child: Text(t.name[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryOrange)),
                ),
                title: Text(t.name),
                subtitle: t.specialty != null ? Text(t.specialty!) : null,
                trailing: t.unread > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                        child: Text('${t.unread}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      )
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(trainerUserId: t.userIdTrainer, trainerName: t.name),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: context.borderCol, borderRadius: BorderRadius.circular(2)),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: AppTheme.primaryOrange),
                title: const Text('Tomar foto'),
                onTap: () { Navigator.pop(sheetCtx); _pickImage(context, ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryOrange),
                title: const Text('Seleccionar de galería'),
                onTap: () { Navigator.pop(sheetCtx); _pickImage(context, ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image != null && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        final success = await context.read<AuthProvider>().updateProfilePhoto(image.path);
        if (context.mounted) {
          Navigator.pop(context);
          if (success) {
            context.read<DashboardProvider>().fetchDashboard();
            context.showSuccessSnackBar('Foto actualizada');
          } else {
            context.showErrorSnackBar('Error al actualizar la foto');
          }
        }
      }
    } catch (_) {
      if (context.mounted) context.showErrorSnackBar('Error al seleccionar la foto');
    }
  }
}

