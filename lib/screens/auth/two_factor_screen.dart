import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_main_screen.dart';
import '../client/promotions_screen.dart';
import '../trainer/trainer_main_screen.dart';

/// Pantalla del código de verificación en dos pasos, mostrada solo para
/// cuentas de administrador/entrenador después de un login por documento
/// exitoso pero pendiente de confirmar (ver [AuthProvider.requiresTwoFactor]).
class TwoFactorScreen extends StatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.verifyTwoFactor(
      code: _codeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Widget destination;
      if (authProvider.isAdmin) {
        destination = const AdminMainScreen();
      } else if (authProvider.isTrainer) {
        destination = const TrainerMainScreen();
      } else {
        destination = const PromotionsScreen();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
      return;
    }

    if (authProvider.errorType == 'challenge_expired') {
      context.showErrorSnackBar(authProvider.error ?? 'La verificación expiró.');
      Navigator.of(context).pop();
      return;
    }

    _codeController.clear();
    context.showErrorSnackBar(authProvider.error ?? 'Código inválido.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor     = Theme.of(context).scaffoldBackgroundColor;
    final cardColor   = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = isDark
        ? AppTheme.primaryOrange.withValues(alpha: 0.2)
        : const Color(0xFFE4E4E7);
    final hintColor   = isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary;
    final labelColor  = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.lightTextPrimary),
          onPressed: () {
            context.read<AuthProvider>().cancelTwoFactor();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryOrange.withValues(alpha: isDark ? 0.14 : 0.08),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppTheme.primaryOrange,
                  size: 40,
                ),
              ).animate().scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    duration: 450.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 24),

              Text(
                'Verificación en dos pasos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 8),

              Text(
                'Ingresa el código de 6 dígitos de tu app de autenticación',
                style: TextStyle(fontSize: 13, color: labelColor),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 220.ms),

              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (_) => _handleVerify(),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                  cursorColor: AppTheme.primaryOrange,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: cardColor,
                    hintText: '000000',
                    hintStyle: TextStyle(
                      fontSize: 26,
                      letterSpacing: 10,
                      color: hintColor.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa el código';
                    if (v.length != 6) return 'El código debe tener 6 dígitos';
                    return null;
                  },
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0, delay: 300.ms),

              const SizedBox(height: 24),

              _buildVerifyButton().animate().fadeIn(delay: 380.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
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
          onTap: _handleVerify,
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
              child: Text(
                'VERIFICAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
