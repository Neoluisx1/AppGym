@echo off
chcp 65001 > nul
color 0A
cls

echo ═══════════════════════════════════════════════════════
echo ========================================
echo GENERAR APK/AAB DE RELEASE - MEGALIFE GYM
echo ========================================
echo.
echo Este script generara el APK o AAB firmado para Play Store.
echo.
echo REQUISITOS PREVIOS:
echo 1. Haber ejecutado GENERAR_KEYSTORE.bat
echo 2. Haber creado el archivo android\key.properties
echo.
pause

echo.
echo Verificando keystore...
if not exist "android\key.properties" (
    echo.
    echo ERROR: No se encontro el archivo key.properties
    echo.
    echo Por favor:
    echo 1. Ejecuta GENERAR_KEYSTORE.bat primero
    echo 2. Copia key.properties.example a key.properties
    echo 3. Edita key.properties con tus contrasenas
    echo.
if %errorlevel% neq 0 (
    echo ❌ Error al limpiar el proyecto
    pause
    exit /b 1
)
echo ✓ Proyecto limpiado

echo.
echo ═══════════════════════════════════════════════════════
echo    PASO 2: Obtener dependencias
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
echo    PASO 3: Seleccionar tipo de build
echo ═══════════════════════════════════════════════════════
echo.
echo 1. AAB (Android App Bundle) - Recomendado para Play Store
echo 2. APK - Para distribución directa
echo 3. Ambos
echo.
set /p choice="Selecciona una opción (1-3): "

if "%choice%"=="1" goto build_aab
if "%choice%"=="2" goto build_apk
if "%choice%"=="3" goto build_both
echo Opción inválida
pause
exit /b 1

:build_aab
echo.
echo ═══════════════════════════════════════════════════════
echo    Generando AAB...
echo ═══════════════════════════════════════════════════════
echo.
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar AAB
    pause
    exit /b 1
)
echo.
echo ✓ AAB generado exitosamente
echo.
echo 📁 Ubicación: build\app\outputs\bundle\release\app-release.aab
goto end

:build_apk
echo.
echo ═══════════════════════════════════════════════════════
echo    Generando APK...
echo ═══════════════════════════════════════════════════════
echo.
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar APK
    pause
    exit /b 1
)
echo.
echo ✓ APK generado exitosamente
echo.
echo 📁 Ubicación: build\app\outputs\flutter-apk\app-release.apk
goto end

:build_both
echo.
echo ═══════════════════════════════════════════════════════
echo    Generando AAB...
echo ═══════════════════════════════════════════════════════
echo.
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar AAB
    pause
    exit /b 1
)
echo ✓ AAB generado

echo.
echo ═══════════════════════════════════════════════════════
echo    Generando APK...
echo ═══════════════════════════════════════════════════════
echo.
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar APK
    pause
    exit /b 1
)
echo ✓ APK generado

echo.
echo ✓ Ambos archivos generados exitosamente
echo.
echo 📁 AAB: build\app\outputs\bundle\release\app-release.aab
echo 📁 APK: build\app\outputs\flutter-apk\app-release.apk

:end
echo.
echo ═══════════════════════════════════════════════════════
echo    ✅ PROCESO COMPLETADO
echo ═══════════════════════════════════════════════════════
echo.
echo PRÓXIMOS PASOS:
echo 1. Prueba el APK en un dispositivo real
echo 2. Verifica que todas las funciones trabajen correctamente
echo 3. Sube el AAB a Google Play Console
echo.
pause
