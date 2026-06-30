import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dynamic branding (loaded from API) ──────────────────────────────────────
  static Color primaryColor = const Color(0xFFF97316);
  static String companyLogo = '';
  static String companyName = 'Mega Life Fitness';
  static String gymTourVideoUrl = '';
  static String companyPhone = '';
  static String companyEmail = '';
  static String companyWhatsapp = '';

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF080808);
  static const Color surfaceDark    = Color(0xFF141414);
  static const Color cardDark       = Color(0xFF1E1E1E);
  static const Color borderColor    = Color(0xFF2A2A2A);

  // ── Orange palette ───────────────────────────────────────────────────────────
  static const Color primaryOrange      = Color(0xFFF97316);
  static const Color primaryOrangeLight = Color(0xFFFB923C);
  static const Color primaryOrangeDark  = Color(0xFFEA580C);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary  = Color(0xFF555555);

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor   = Color(0xFFEF4444);
  static const Color infoColor    = Color(0xFF3B82F6);

  // ── Aliases ─────────────────────────────────────────────────────────────────
  static const Color cardBackground = cardDark;
  static const Color inputBackground = cardDark;

  // ── Spacing ─────────────────────────────────────────────────────────────────
  static const double spacing4  = 4.0;
  static const double spacing8  = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // ── Radii ───────────────────────────────────────────────────────────────────
  static const double radiusSmall  = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge  = 18.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 999.0;

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF242424), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryOrange.withValues(alpha: 0.5),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  // ── Glassmorphism decoration ─────────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    Color? tint,
    double opacity = 0.08,
    double borderOpacity = 0.15,
    double radius = radiusLarge,
  }) {
    final base = tint ?? Colors.white;
    return BoxDecoration(
      color: base.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: base.withValues(alpha: borderOpacity), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ── Light theme colors (semantic) ────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightBorder     = Color(0xFFE4E4E7);
  static const Color lightTextPrimary   = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF71717A);
  static const Color lightTextTertiary  = Color(0xFFA1A1AA);

  // ── Light theme ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final poppins = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        primaryContainer: primaryOrangeDark,
        secondary: primaryOrangeLight,
        surface: lightSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        iconTheme: const IconThemeData(color: lightTextPrimary, size: 24),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: const EdgeInsets.all(spacing8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing16),
        hintStyle: const TextStyle(color: lightTextTertiary),
        labelStyle: const TextStyle(color: lightTextSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primaryOrange.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryOrange, size: 24);
          }
          return const IconThemeData(color: lightTextTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: primaryOrange);
          }
          return GoogleFonts.poppins(fontSize: 11, color: lightTextTertiary);
        }),
        elevation: 0,
        height: 64,
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1, space: spacing16),
      dialogTheme: DialogTheme(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: poppins.copyWith(
        displayLarge:  poppins.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextPrimary),
        displayMedium: poppins.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextPrimary),
        displaySmall:  poppins.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineLarge:  poppins.headlineLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: lightTextPrimary),
        headlineMedium: poppins.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
        headlineSmall:  poppins.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
        bodyLarge:  poppins.bodyLarge?.copyWith(fontSize: 16, color: lightTextPrimary),
        bodyMedium: poppins.bodyMedium?.copyWith(fontSize: 14, color: lightTextSecondary),
        bodySmall:  poppins.bodySmall?.copyWith(fontSize: 12, color: lightTextTertiary),
        labelLarge:  poppins.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: lightTextPrimary),
        labelMedium: poppins.labelMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: lightTextPrimary),
        labelSmall:  poppins.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: lightTextSecondary),
      ),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final poppins = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        primaryContainer: primaryOrangeDark,
        secondary: primaryOrangeLight,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.all(spacing8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing16),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: primaryOrange.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryOrange, size: 24);
          }
          return const IconThemeData(color: textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: primaryOrange);
          }
          return GoogleFonts.poppins(fontSize: 11, color: textTertiary);
        }),
        elevation: 0,
        height: 64,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryOrange,
        linearTrackColor: borderColor,
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1, space: spacing16),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primaryOrange,
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.poppins(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: poppins.copyWith(
        displayLarge:  poppins.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: poppins.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        displaySmall:  poppins.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        headlineLarge:  poppins.headlineLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: poppins.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall:  poppins.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:  poppins.bodyLarge?.copyWith(fontSize: 16, color: textPrimary),
        bodyMedium: poppins.bodyMedium?.copyWith(fontSize: 14, color: textSecondary),
        bodySmall:  poppins.bodySmall?.copyWith(fontSize: 12, color: textTertiary),
        labelLarge:  poppins.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium: poppins.labelMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelSmall:  poppins.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
      ),
    );
  }

  // ── Load configuration from backend ─────────────────────────────────────────
  static Future<void> loadConfiguration(Map<String, dynamic> config) async {
    final logo = config['logo_url'] as String?;
    final name = config['name'] as String?;
    final videoUrl = config['tour_video_url'] as String?;
    final colorHex = config['primary_color'] as String?;

    if (logo != null && logo.isNotEmpty) companyLogo = logo;
    if (name != null && name.isNotEmpty) companyName = name;
    if (videoUrl != null && videoUrl.isNotEmpty) gymTourVideoUrl = videoUrl;
    if (colorHex != null && colorHex.isNotEmpty) {
      try {
        primaryColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    final phone = config['phone'] as String?;
    final email = config['email'] as String?;
    final whatsapp = config['whatsapp'] as String?;
    if (phone != null) companyPhone = phone;
    if (email != null) companyEmail = email;
    if (whatsapp != null) companyWhatsapp = whatsapp;
  }

  // ── Logo widget ──────────────────────────────────────────────────────────────
  static Widget getLogo({double width = 120, double height = 60}) {
    if (companyLogo.isNotEmpty) {
      return Image.network(
        companyLogo,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _getLocalLogo(width, height),
      );
    }
    return _getLocalLogo(width, height);
  }

  static Widget _getLocalLogo(double width, double height) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: orangeGradient,
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        child: Center(
          child: Text(
            companyName.isNotEmpty ? companyName[0].toUpperCase() : 'G',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ── Context extensions ────────────────────────────────────────────────────────
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // ── Colores adaptativos (claro / oscuro) ────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Fondo de tarjetas y contenedores
  Color get cardColor => isDark ? AppTheme.cardDark : Colors.white;

  /// Fondo de superficies secundarias (bottom sheets, dialogs)
  Color get surfaceColor => isDark ? AppTheme.surfaceDark : Colors.white;

  /// Borde de tarjetas y campos
  Color get borderCol => isDark ? AppTheme.borderColor : AppTheme.lightBorder;

  /// Color de texto secundario adaptativo
  Color get textSecondCol =>
      isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;

  /// Color de texto terciario adaptativo
  Color get textTertCol =>
      isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary;

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.successColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
