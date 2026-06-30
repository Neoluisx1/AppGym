@echo off
echo ========================================
echo COPIAR LOGO AL SPLASH SCREEN
echo ========================================
echo.
echo Este script copiara tu logo como splash_logo.png
echo.
pause

echo.
echo Copiando logo...
echo.

REM Copiar el logo como splash_logo
copy assets\images\logo.png android\app\src\main\res\drawable\splash_logo.png /Y

echo.
echo ========================================
echo LOGO COPIADO EXITOSAMENTE
echo ========================================
echo.
echo Ahora ejecuta: flutter run
echo.
pause
