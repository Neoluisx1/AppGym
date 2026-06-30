@echo off
chcp 65001 > nul
color 0E
cls

echo ═══════════════════════════════════════════════════════
echo    🔍 VERIFICAR CAMBIOS Y EJECUTAR APP
echo ═══════════════════════════════════════════════════════
echo.
echo Este script verificará que los cambios se aplicaron
echo y ejecutará la app con recompilación completa.
echo.

echo CAMBIOS APLICADOS:
echo ✓ lib/models/user_model.dart - Línea 110
echo   photoUrl: json['photo'] ?? json['photo_url']
echo.
echo ✓ lib/models/dashboard_model.dart - Línea 60
echo   photoUrl: json['photo'] ?? json['photo_url']
echo.
echo ✓ lib/screens/client/dashboard_screen.dart - Líneas 47-52
echo   Foto agregada en AppBar
echo.
echo ✓ lib/providers/dashboard_provider.dart
echo   Logs de depuración agregados
echo.
pause

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 1: Limpiar proyecto
echo ═══════════════════════════════════════════════════════
echo.
call flutter clean
echo.

echo ═══════════════════════════════════════════════════════
echo    PASO 2: Obtener dependencias
echo ═══════════════════════════════════════════════════════
echo.
call flutter pub get
echo.

echo ═══════════════════════════════════════════════════════
echo    PASO 3: Ejecutar app
echo ═══════════════════════════════════════════════════════
echo.
echo IMPORTANTE: Observa los logs que empiezan con:
echo   === DASHBOARD DATA ===
echo   === AFTER PARSING ===
echo.
echo Estos logs mostrarán la URL de la foto que recibe Flutter.
echo.
pause

call flutter run
