@echo off
chcp 65001 > nul
color 0D
cls

echo ═══════════════════════════════════════════════════════
echo    🔍 EJECUTAR APP CON LOGS DE DEPURACIÓN
echo ═══════════════════════════════════════════════════════
echo.
echo Este script ejecutará la app y mostrará TODOS los logs
echo de depuración para identificar por qué la foto no aparece.
echo.
echo BUSCA ESTOS LOGS:
echo   📱 Dashboard build - photoUrl: [URL]
echo   🖼️ Cargando imagen: ...
echo   ❌ ERROR cargando imagen: ...
echo.
pause

echo.
echo Ejecutando app...
echo.
flutter run

pause
