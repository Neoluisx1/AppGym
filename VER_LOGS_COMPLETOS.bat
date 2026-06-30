@echo off
chcp 65001 > nul
color 0B
cls

echo ═══════════════════════════════════════════════════════
echo    📋 VER LOGS COMPLETOS DE FLUTTER
echo ═══════════════════════════════════════════════════════
echo.
echo Este script mostrará TODOS los logs de la app Flutter
echo incluyendo los logs de depuración que agregamos.
echo.
echo IMPORTANTE: 
echo - Abre la app en tu teléfono
echo - Inicia sesión con documento 6672047
echo - Busca los logs que dicen "=== DASHBOARD DATA ==="
echo.
pause

echo.
echo Mostrando logs...
echo.
flutter logs

pause
