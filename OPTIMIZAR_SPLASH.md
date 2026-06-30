# PROBLEMA CON SPLASH_BACKGROUND.PNG

## 🔴 PROBLEMA IDENTIFICADO

El archivo `splash_background.png` (3.8 MB) es **demasiado grande** para Android.

Android tiene un límite de memoria para recursos drawable (~2-3 MB dependiendo del dispositivo). Cuando la imagen excede este límite, Android falla silenciosamente y muestra el fondo negro por defecto.

## ✅ SOLUCIÓN

Necesitas **optimizar la imagen** antes de usarla:

### Paso 1: Reducir tamaño de la imagen

**Dimensiones recomendadas:**
- 1080x1920 px (Full HD vertical)
- O 1440x2560 px (2K vertical) máximo

**Tamaño de archivo:**
- Máximo 500 KB (idealmente menos de 300 KB)

### Paso 2: Herramientas para optimizar

**Opción A - Online (más fácil):**
1. Ve a https://tinypng.com/
2. Sube tu `splash_background.png`
3. Descarga la versión optimizada
4. Reemplaza el archivo en: `android/app/src/main/res/drawable/splash_background.png`

**Opción B - Photoshop/GIMP:**
1. Abre la imagen
2. Image → Image Size → 1080x1920 px
3. File → Export As → PNG
4. Ajusta calidad para que quede < 500 KB

**Opción C - Squoosh (Google):**
1. Ve a https://squoosh.app/
2. Arrastra tu imagen
3. Ajusta compresión hasta < 500 KB
4. Descarga y reemplaza

### Paso 3: Después de optimizar

```bash
# Reemplaza el archivo en:
android/app/src/main/res/drawable/splash_background.png

# Luego ejecuta:
flutter clean
flutter run
```

## 🎨 ALTERNATIVA TEMPORAL

Si no puedes optimizar la imagen ahora, puedes usar un gradiente de color:

El `launch_background.xml` actual está configurado para usar `splash_background.png`, pero como es muy grande, Android lo ignora y muestra negro.

## 📊 COMPARACIÓN DE TAMAÑOS

- ❌ Actual: 3.8 MB (demasiado grande)
- ✅ Recomendado: < 500 KB
- ⭐ Ideal: 200-300 KB

## 🔧 VERIFICACIÓN

Después de optimizar, verifica el tamaño:
```bash
dir android\app\src\main\res\drawable\splash_background.png
```

Debe mostrar menos de 500,000 bytes.
