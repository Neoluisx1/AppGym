@echo off
echo ========================================
echo GENERAR KEYSTORE PARA PLAY STORE
echo ========================================
echo.
echo Este script generara el archivo keystore necesario para firmar la app.
echo.
echo IMPORTANTE: Guarda bien la contrasena que ingreses!
echo Si la pierdes, NO podras actualizar la app en Play Store.
echo.
pause

cd android\app

echo.
echo Generando keystore...
echo.

keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

echo.
echo ========================================
echo KEYSTORE GENERADO EXITOSAMENTE
echo ========================================
echo.
echo El archivo se guardo en: android\app\upload-keystore.jks
echo.
echo SIGUIENTE PASO:
echo 1. Copia el archivo key.properties.example a key.properties
echo 2. Edita key.properties con tus contrasenas
echo 3. Ejecuta GENERAR_RELEASE.bat para crear el APK/AAB
echo.
pause
