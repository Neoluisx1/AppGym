@echo off
echo ========================================
echo CREAR ARCHIVO key.properties
echo ========================================
echo.
echo Este script creara el archivo key.properties
echo.
set /p STORE_PASSWORD="Ingresa la contrasena del keystore: "
set /p KEY_PASSWORD="Ingresa la contrasena de la key (misma que arriba): "
echo.

(
echo storePassword=%STORE_PASSWORD%
echo keyPassword=%KEY_PASSWORD%
echo keyAlias=release
echo storeFile=../app/release-keystore.jks
) > android\key.properties

echo.
echo ========================================
echo ARCHIVO CREADO EXITOSAMENTE
echo ========================================
echo.
echo El archivo android\key.properties ha sido creado.
echo.
echo Ahora ejecuta: flutter build appbundle --release
echo.
pause
