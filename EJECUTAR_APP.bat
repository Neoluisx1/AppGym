@echo off
echo.
echo ========================================
echo      EJECUTAR GYM APP - FLUTTER
echo ========================================
echo.
echo Iniciando aplicacion Flutter...
echo.
echo IMPORTANTE:
echo - Asegurate que el backend este corriendo en http://localhost:8000
echo - Conecta un dispositivo o inicia un emulador
echo.
echo NOTA: Si usas emulador Android, la app se conectara
echo automaticamente a http://10.0.2.2:8000
echo.
echo Para dispositivo fisico, edita: lib/core/constants/env_config.dart
echo Ver: CONFIGURACION_API.md para mas detalles
echo.
echo ========================================
echo.

flutter run

echo.
echo App cerrada.
pause
