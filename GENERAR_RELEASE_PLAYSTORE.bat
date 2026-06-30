@echo off
chcp 65001 > nul
cls

echo ========================================
echo GENERAR APK/AAB - MEGALIFE GYM
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
    pause
    exit /b 1
)

echo Keystore configurado correctamente!
echo.

:menu
echo ========================================
echo SELECCIONA EL TIPO DE BUILD
echo ========================================
echo.
echo 1. APK (para instalar directamente en dispositivos)
echo 2. AAB (para subir a Play Store - RECOMENDADO)
echo 3. Ambos
echo 4. Salir
echo.
set /p opcion="Ingresa tu opcion (1-4): "

if "%opcion%"=="1" goto build_apk
if "%opcion%"=="2" goto build_aab
if "%opcion%"=="3" goto build_both
if "%opcion%"=="4" goto end
echo Opcion invalida
goto menu

:build_apk
echo.
echo ========================================
echo GENERANDO APK DE RELEASE
echo ========================================
echo.
call flutter build apk --release
if %errorlevel% neq 0 (
    echo.
    echo ERROR al generar APK
    pause
    exit /b 1
)
echo.
echo ========================================
echo APK GENERADO EXITOSAMENTE
echo ========================================
echo.
echo Ubicacion: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
goto end

:build_aab
echo.
echo ========================================
echo GENERANDO AAB DE RELEASE
echo ========================================
echo.
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo.
    echo ERROR al generar AAB
    pause
    exit /b 1
)
echo.
echo ========================================
echo AAB GENERADO EXITOSAMENTE
echo ========================================
echo.
echo Ubicacion: build\app\outputs\bundle\release\app-release.aab
echo.
echo SIGUIENTE PASO:
echo Sube el archivo AAB a Google Play Console
echo.
pause
goto end

:build_both
echo.
echo ========================================
echo GENERANDO APK Y AAB DE RELEASE
echo ========================================
echo.
echo Generando APK...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR al generar APK
    pause
    exit /b 1
)
echo.
echo Generando AAB...
call flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ERROR al generar AAB
    pause
    exit /b 1
)
echo.
echo ========================================
echo BUILDS GENERADOS EXITOSAMENTE
echo ========================================
echo.
echo APK: build\app\outputs\flutter-apk\app-release.apk
echo AAB: build\app\outputs\bundle\release\app-release.aab
echo.
pause
goto end

:end
echo.
echo Proceso finalizado.
pause
