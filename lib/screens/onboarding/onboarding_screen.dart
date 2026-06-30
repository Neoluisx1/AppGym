import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      title: 'Entrena sin límites',
      subtitle: 'Accede a tu rutina personalizada, registra cada sesión y supera tus metas día a día.',
      icon: Icons.fitness_center_rounded,
      color1: Color(0xFFFF8C00),
      color2: Color(0xFFB03A00),
      watermark: 'FUERZA',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    _SlideData(
      title: 'Controla tu progreso',
      subtitle: 'Visualiza tu evolución, mide tus avances y celebra cada logro con estadísticas detalladas.',
      icon: Icons.trending_up_rounded,
      color1: Color(0xFF10B981),
      color2: Color(0xFF047857),
      watermark: 'EVOLUCIÓN',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    _SlideData(
      title: 'Tu membresía, siempre contigo',
      subtitle: 'Accede al gimnasio con tu código QR, revisa tus asistencias y renueva tu plan desde la app.',
      icon: Icons.qr_code_2_rounded,
      color1: Color(0xFF8B5CF6),
      color2: Color(0xFF5B21B6),
      watermark: 'ACCESO',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  Future<void> _goNext() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [
          // ── Slides ────────────────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
          ),

          // ── Bottom overlay ────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF080808).withValues(alpha: 0.95),
                    const Color(0xFF080808),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Indicadores de página ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? slide.color1
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // ── Botones ───────────────────────────────────────────────────
                  if (isLast)
                    // Botón "Comenzar" ancho completo
                    _ActionButton(
                      label: 'COMENZAR',
                      color1: slide.color1,
                      color2: slide.color2,
                      fullWidth: true,
                      onTap: _finish,
                    )
                  else
                    Row(
                      children: [
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Omitir',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _ActionButton(
                          label: 'Siguiente',
                          color1: slide.color1,
                          color2: slide.color2,
                          onTap: _goNext,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Datos del slide ─────────────────────────────────────────────────────────

class _SlideData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color1;
  final Color color2;
  final String watermark;
  // Si colocas la imagen en assets/images/ con este nombre, se usará automáticamente.
  // Si no existe, se muestra el diseño con ícono.
  final String imagePath;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.watermark,
    required this.imagePath,
  });
}

// ── Widget de cada slide ────────────────────────────────────────────────────

class _SlideWidget extends StatelessWidget {
  final _SlideData slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        // ── Ilustración superior ────────────────────────────────────────────
        SizedBox(
          height: size.height * 0.56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen real (si existe) o fondo degradado con ícono
              Image.asset(
                slide.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildIconIllustration(),
              ),

              // Degradado inferior para fusionar con el fondo oscuro
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: size.height * 0.22,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFF080808)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Texto inferior ───────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0, delay: 150.ms),

                const SizedBox(height: 14),

                Text(
                  slide.subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.65,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0, delay: 250.ms),
              ],
            ),
          ),
        ),

        // Espacio para el panel inferior
        const SizedBox(height: 140),
      ],
    );
  }

  // Fallback cuando no existe la imagen en assets
  Widget _buildIconIllustration() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo degradado
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                slide.color1.withValues(alpha: 0.9),
                slide.color2.withValues(alpha: 0.7),
                const Color(0xFF080808),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // Círculo decorativo superior derecho
        Positioned(
          top: -80, right: -80,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Círculo decorativo inferior izquierdo
        Positioned(
          bottom: 60, left: -50,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
        // Watermark
        Center(
          child: Text(
            slide.watermark,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Ícono principal
        Center(
          child: Container(
            width: 150, height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
              boxShadow: [
                BoxShadow(
                  color: slide.color1.withValues(alpha: 0.45),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(slide.icon, size: 72, color: Colors.white),
          )
              .animate()
              .scale(
                begin: const Offset(0.75, 0.75),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
        ),
      ],
    );
  }
}

// ── Botón de acción ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.color1,
    required this.color2,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: fullWidth ? 0 : 28,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color1.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
