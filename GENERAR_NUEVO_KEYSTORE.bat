@echo off
echo ========================================
echo GENERAR NUEVO KEYSTORE PARA PLAY STORE
echo ========================================
echo.
echo Este script generara un nuevo keystore firmado.
echo.
echo IMPORTANTE: Guarda las contrasenas que ingreses.
echo Las necesitaras para futuras actualizaciones.
echo.
pause

echo.
echo Generando keystore...
echo.

REM Generar el keystore
keytool -genkey -v -keystore android\app\release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release

echo.
echo ========================================
echo KEYSTORE GENERADO EXITOSAMENTE
echo ========================================
echo.
echo El keystore se guardo en: android\app\release-keystore.jks
echo.
echo SIGUIENTE PASO:
echo Actualiza el archivo android\key.properties con:
echo.
echo storePassword=LA_CONTRASENA_QUE_USASTE
echo keyPassword=LA_CONTRASENA_QUE_USASTE
echo keyAlias=release
echo storeFile=../app/release-keystore.jks
echo.
pause
