@echo off
echo ========================================
echo CORREGIR key.properties - RUTA CORRECTA
echo ========================================
echo.
set /p STORE_PASSWORD="Ingresa la contrasena del keystore: "
set /p KEY_PASSWORD="Ingresa la contrasena de la key: "
echo.

(
echo storePassword=%STORE_PASSWORD%
echo keyPassword=%KEY_PASSWORD%
echo keyAlias=release
echo storeFile=app/release-keystore.jks
) > android\key.properties

echo.
echo ========================================
echo ARCHIVO CORREGIDO
echo ========================================
echo.
echo Ruta configurada: app/release-keystore.jks
echo.
echo Ahora ejecuta: flutter build appbundle --release
echo.
pause
