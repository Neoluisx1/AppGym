@echo off
chcp 65001 > nul
color 0C
cls

echo ═══════════════════════════════════════════════════════
echo    🔄 RECOMPILAR APP FLUTTER COMPLETAMENTE
echo ═══════════════════════════════════════════════════════
echo.
echo Este script forzará una recompilación completa de la app
echo para aplicar los cambios en los modelos de datos.
echo.
echo IMPORTANTE: Los cambios en modelos NO se aplican con
echo hot reload. Necesitas recompilar completamente.
echo.
pause

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 1: Detener la app actual
echo ═══════════════════════════════════════════════════════
echo.
echo Presiona Ctrl+C en la terminal donde está corriendo Flutter
echo o cierra la app en tu teléfono.
echo.
pause

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 2: Limpiar proyecto
echo ═══════════════════════════════════════════════════════
echo.
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Error al limpiar el proyecto
    pause
    exit /b 1
)
echo ✓ Proyecto limpiado

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 3: Obtener dependencias
echo ═══════════════════════════════════════════════════════
echo.
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error al obtener dependencias
    pause
    exit /b 1
)
echo ✓ Dependencias obtenidas

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 4: Ejecutar app en modo debug
echo ═══════════════════════════════════════════════════════
echo.
echo Conecta tu teléfono y asegúrate de que esté en modo depuración USB
echo.
pause

echo.
echo Ejecutando app...
echo.
flutter run

echo.
echo ═══════════════════════════════════════════════════════
echo    ✅ PROCESO COMPLETADO
echo ═══════════════════════════════════════════════════════
echo.
pause
