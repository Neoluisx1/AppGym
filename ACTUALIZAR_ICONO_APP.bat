@echo off
echo ========================================
echo ACTUALIZAR ICONO DE LA APP
echo ========================================
echo.
echo Este script copiara tu logo a los iconos de Android
echo.
pause

echo.
echo Copiando logo a carpetas de iconos...
echo.

REM Copiar el logo a todas las carpetas de mipmap
copy assets\images\logo.png android\app\src\main\res\mipmap-hdpi\ic_launcher.png /Y
copy assets\images\logo.png android\app\src\main\res\mipmap-mdpi\ic_launcher.png /Y
copy assets\images\logo.png android\app\src\main\res\mipmap-xhdpi\ic_launcher.png /Y
copy assets\images\logo.png android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png /Y
copy assets\images\logo.png android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png /Y

echo.
echo ========================================
echo ICONO ACTUALIZADO EXITOSAMENTE
echo ========================================
echo.
echo El logo se ha copiado a todas las carpetas de iconos.
echo.
echo SIGUIENTE PASO:
echo Ejecuta: flutter clean
echo Luego: flutter run
echo.
pause
