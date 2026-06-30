@echo off
chcp 65001 >nul
echo ========================================
echo   GENERAR AAB CORREGIDO v1.0.2
echo ========================================
echo.
echo 📋 CORRECCIONES APLICADAS:
echo   ✅ URL de API: https://megalifegym.com/api/v1
echo   ✅ Renovación de membresías: DESHABILITADA
echo   ✅ Versión: 1.0.2 (versionCode 3)
echo.
echo ========================================
pause

echo.
echo 🧹 Limpiando proyecto...
call flutter clean
if errorlevel 1 (
    echo ❌ Error al limpiar el proyecto
    pause
    exit /b 1
)

echo.
echo 📦 Obteniendo dependencias...
call flutter pub get
if errorlevel 1 (
    echo ❌ Error al obtener dependencias
    pause
    exit /b 1
)

echo.
echo 🔨 Compilando AAB en modo release...
echo.
call flutter build appbundle --release
if errorlevel 1 (
    echo.
    echo ❌ Error al compilar el AAB
    echo.
    echo 💡 Verifica:
    echo   1. Que el archivo key.properties existe
    echo   2. Que las contraseñas del keystore sean correctas
    echo   3. Que no haya errores de compilación
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   ✅ AAB GENERADO EXITOSAMENTE
echo ========================================
echo.
echo 📍 Ubicación del archivo:
echo    build\app\outputs\bundle\release\app-release.aab
echo.
echo 📊 Información de la versión:
echo    • Versión: 1.0.2
echo    • Version Code: 3
echo    • Package: com.megalifegym.app
echo.
echo 🔧 Cambios en esta versión:
echo    • URL de API corregida a producción
echo    • Renovación de membresías deshabilitada
echo    • Los clientes deben contactar al admin para renovar
echo.
echo 📤 PRÓXIMOS PASOS:
echo    1. Ir a Play Console
echo    2. Crear nueva versión en Producción
echo    3. Subir: build\app\outputs\bundle\release\app-release.aab
echo    4. Completar información de la versión
echo    5. Enviar a revisión
echo.
echo ========================================
pause
