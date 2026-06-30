@echo off
echo ========================================
echo ACTUALIZAR key.properties
echo ========================================
echo.
set /p STORE_PASSWORD="Ingresa la contrasena del keystore: "
set /p KEY_PASSWORD="Ingresa la contrasena de la key: "
echo.

(
echo storePassword=%STORE_PASSWORD%
echo keyPassword=%KEY_PASSWORD%
echo keyAlias=release
echo storeFile=release-keystore.jks
) > android\key.properties

echo.
echo ========================================
echo ARCHIVO ACTUALIZADO
echo ========================================
echo.
echo Ahora ejecuta: flutter build appbundle --release
echo.
pause
