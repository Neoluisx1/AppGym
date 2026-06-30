import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/services/api_service.dart';
import '../client/promotions_screen.dart';
import '../trainer/trainer_main_screen.dart';
import '../settings/server_config_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _documentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.loginByDocumentSafe(
      document: _documentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final isTrainer = context.read<AuthProvider>().isTrainer;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isTrainer ? const TrainerMainScreen() : const PromotionsScreen(),
        ),
      );
      return;
    }

    final errorType = authProvider.errorType;
    final whatsapp  = authProvider.errorWhatsapp ?? '';
    final message   = authProvider.error ?? 'Error al iniciar sesión';

    if (errorType == 'not_found') {
      _showContactDialog(
        icon: Icons.person_off_outlined,
        title: 'No registrado',
        message: 'El número de documento no está registrado en el sistema.',
        whatsapp: whatsapp,
        whatsappText: 'Quiero registrarme en el gimnasio',
      );
    } else if (errorType == 'membership_expired') {
      _showContactDialog(
        icon: Icons.card_membership_outlined,
        title: 'Membresía vencida',
        message: 'Tu membresía ha vencido. Renuévala para volver a acceder.',
        whatsapp: whatsapp,
        whatsappText: 'Hola, quiero renovar mi membresía',
      );
    } else if (errorType == 'inactive') {
      _showContactDialog(
        icon: Icons.block_outlined,
        title: 'Cuenta inactiva',
        message: 'Tu cuenta está inactiva. Contáctanos para activarla.',
        whatsapp: whatsapp,
        whatsappText: 'Hola, quiero activar mi cuenta',
      );
    } else {
      context.showErrorSnackBar(message);
    }
  }

  void _showContactDialog({
    required IconData icon,
    required String title,
    required String message,
    required String whatsapp,
    required String whatsappText,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.errorColor, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: ctx.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(message, style: ctx.textTheme.bodyMedium, textAlign: TextAlign.center),
            if (whatsapp.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openWhatsApp(whatsapp, whatsappText);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Contactar por WhatsApp'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(String number, String text) async {
    final clean = number.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://wa.me/$clean?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServerConfigScreen()),
    );
    if (result == true && mounted) {
      final settingsProvider = context.read<SettingsProvider>();
      ApiService().updateBaseUrl(settingsProvider.serverUrl);
      context.showSuccessSnackBar('Configuración actualizada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Colores adaptativos
    final bgColor      = Theme.of(context).scaffoldBackgroundColor;
    final cardColor    = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor  = isDark
        ? AppTheme.primaryOrange.withValues(alpha: 0.2)
        : const Color(0xFFE4E4E7);
    final hintColor    = isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary;
    final labelColor   = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final subtleColor  = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Acento decorativo superior ───────────────────────────────────────
          Positioned(
            top: -size.height * 0.08,
            left: size.width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtleColor,
              ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Logo
                  _buildLogo(isDark)
                      .animate()
                      .scale(
                        begin: const Offset(0.65, 0.65),
                        end: const Offset(1.0, 1.0),
                        duration: 650.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 450.ms),

                  const SizedBox(height: 24),

                  // Nombre del gimnasio
                  Text(
                    AppTheme.companyName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 400.ms)
                      .slideY(begin: 0.15, end: 0, delay: 180.ms),

                  const SizedBox(height: 6),

                  Text(
                    'Ingresa con tu número de documento',
                    style: TextStyle(
                      fontSize: 13,
                      color: labelColor,
                    ),
                  ).animate().fadeIn(delay: 260.ms),

                  SizedBox(height: size.height * 0.07),

                  // Etiqueta
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NÚMERO DE DOCUMENTO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: hintColor,
                      ),
                    ),
                  ).animate().fadeIn(delay: 340.ms),

                  const SizedBox(height: 10),

                  // Campo documento
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _documentController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (_) => _handleLogin(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                      cursorColor: AppTheme.primaryOrange,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: '·  ·  ·  ·  ·  ·  ·  ·',
                        hintStyle: TextStyle(
                          fontSize: 22,
                          letterSpacing: 4,
                          color: hintColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: borderColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryOrange,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.errorColor,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.errorColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu documento';
                        if (v.length < 5) return 'Documento inválido';
                        return null;
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.08, end: 0, delay: 400.ms),

                  const SizedBox(height: 20),

                  // Botón ingresar
                  _buildLoginButton()
                      .animate()
                      .fadeIn(delay: 480.ms, duration: 400.ms)
                      .slideY(begin: 0.08, end: 0, delay: 480.ms),

                  const SizedBox(height: 24),

                  // Nota pie
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: hintColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Solo clientes activos pueden acceder',
                        style: TextStyle(
                          fontSize: 12,
                          color: hintColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 580.ms),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // ── Botón configuración ──────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openSettings,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: labelColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Indicador servidor ───────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Consumer<SettingsProvider>(
                  builder: (context, settings, _) => Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: settings.isConfigured
                              ? AppTheme.successColor.withValues(alpha: 0.3)
                              : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: settings.isConfigured
                                ? AppTheme.successColor
                                : hintColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              settings.serverUrl.replaceAll('/api/v1', ''),
                              style: TextStyle(
                                fontSize: 11,
                                color: settings.isConfigured
                                    ? AppTheme.successColor
                                    : hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow exterior
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primaryOrange.withValues(alpha: isDark ? 0.12 : 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Logo
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            border: Border.all(
              color: AppTheme.primaryOrange.withValues(alpha: isDark ? 0.35 : 0.2),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: isDark ? 0.2 : 0.12),
                blurRadius: isDark ? 28 : 16,
                spreadRadius: isDark ? 2 : 0,
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: AppTheme.getLogo(width: 148, height: 148),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.orangeGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: SpinKitThreeBounce(color: Colors.white, size: 20),
            ),
          );
        }
        return GestureDetector(
          onTap: _handleLogin,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'INGRESAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
