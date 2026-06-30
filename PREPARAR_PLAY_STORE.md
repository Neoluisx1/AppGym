# 🚀 GUÍA PARA PUBLICAR EN PLAY STORE

## ✅ CORRECCIONES APLICADAS

### 1. **Problema de Fotos Resuelto**
- ✅ Corregido mapeo de `photo` en `user_model.dart`
- ✅ Corregido mapeo de `photo` en `dashboard_model.dart`
- ✅ Agregada foto en el AppBar del dashboard
- ✅ Backend retorna URL correcta: `http://megalifegym.com/storage/clients/...`

### 2. **Cambios Necesarios**
Los siguientes archivos fueron modificados:
- `lib/models/user_model.dart` - Línea 110
- `lib/models/dashboard_model.dart` - Línea 60
- `lib/screens/client/dashboard_screen.dart` - Líneas 47-52

---

## 📋 PASOS PARA PUBLICAR EN PLAY STORE

### **PASO 1: Actualizar Información de la App**

#### 1.1 Actualizar `pubspec.yaml`
```yaml
name: megalife_gym
description: "Aplicación móvil para Megalife Gym - Gestión de membresías, rutinas y más"
version: 1.0.0+1
```

#### 1.2 Actualizar `android/app/build.gradle.kts`
Cambiar el `applicationId` de `com.example.gym_app` a algo único:
```kotlin
applicationId = "com.megalifegym.app"
```

---

### **PASO 2: Configurar Firma de Release**

#### 2.1 Generar Keystore
Ejecuta este comando en la terminal (reemplaza los valores):
```bash
keytool -genkey -v -keystore C:\Users\TU_USUARIO\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Información a proporcionar:
# - Contraseña del keystore: [GUARDA ESTO EN LUGAR SEGURO]
# - Nombre y apellido: Megalife Gym
# - Unidad organizativa: Gimnasio
# - Organización: Megalife Gym
# - Ciudad: [Tu ciudad]
# - Estado: [Tu estado]
# - Código de país: BO
```

#### 2.2 Crear `android/key.properties`
Crea este archivo con la información del keystore:
```properties
storePassword=TU_CONTRASEÑA_KEYSTORE
keyPassword=TU_CONTRASEÑA_KEY
keyAlias=upload
storeFile=C:/Users/TU_USUARIO/upload-keystore.jks
```

**⚠️ IMPORTANTE:** Agrega `key.properties` al `.gitignore` para no subirlo a Git.

#### 2.3 Actualizar `android/app/build.gradle.kts`
Agrega antes del bloque `android`:
```kotlin
// Cargar propiedades del keystore
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... código existente ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

### **PASO 3: Actualizar AndroidManifest.xml**

Archivo: `android/app/src/main/AndroidManifest.xml`

Asegúrate de tener:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application
        android:label="Megalife Gym"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <!-- Resto del contenido -->
    </application>
</manifest>
```

---

### **PASO 4: Crear Iconos de la App**

#### 4.1 Generar iconos
Usa una herramienta como [AppIcon.co](https://appicon.co/) o [Icon Kitchen](https://icon.kitchen/)

Sube tu logo y genera todos los tamaños necesarios.

#### 4.2 Reemplazar iconos
Coloca los iconos generados en:
- `android/app/src/main/res/mipmap-hdpi/`
- `android/app/src/main/res/mipmap-mdpi/`
- `android/app/src/main/res/mipmap-xhdpi/`
- `android/app/src/main/res/mipmap-xxhdpi/`
- `android/app/src/main/res/mipmap-xxxhdpi/`

---

### **PASO 5: Generar APK/AAB de Release**

#### 5.1 Limpiar proyecto
```bash
flutter clean
flutter pub get
```

#### 5.2 Generar AAB (recomendado para Play Store)
```bash
flutter build appbundle --release
```

El archivo se generará en:
```
build/app/outputs/bundle/release/app-release.aab
```

#### 5.3 Generar APK (para distribución directa)
```bash
flutter build apk --release
```

El archivo se generará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### **PASO 6: Probar el APK de Release**

#### 6.1 Instalar en dispositivo
```bash
flutter install --release
```

#### 6.2 Verificar funcionalidad
- ✅ Login funciona
- ✅ Dashboard carga correctamente
- ✅ Fotos se muestran
- ✅ Productos de tienda se ven
- ✅ Navegación funciona

---

### **PASO 7: Preparar Recursos para Play Store**

#### 7.1 Capturas de pantalla
Necesitas capturas de:
- Pantalla de login
- Dashboard
- Perfil con foto
- Tienda de productos
- Rutinas
- Clases grupales

Tamaños requeridos:
- Teléfono: 1080 x 1920 px (mínimo 2 capturas, máximo 8)
- Tablet 7": 1200 x 1920 px (opcional)
- Tablet 10": 1600 x 2560 px (opcional)

#### 7.2 Icono de la app
- 512 x 512 px
- PNG de 32 bits
- Fondo transparente o de color

#### 7.3 Gráfico destacado
- 1024 x 500 px
- JPG o PNG de 24 bits

#### 7.4 Descripción
**Título:** Megalife Gym (máximo 50 caracteres)

**Descripción corta:** (máximo 80 caracteres)
```
Gestiona tu membresía, rutinas y progreso en Megalife Gym
```

**Descripción completa:** (máximo 4000 caracteres)
```
🏋️ Megalife Gym - Tu Compañero de Fitness

Lleva tu experiencia en el gimnasio al siguiente nivel con la app oficial de Megalife Gym.

✨ CARACTERÍSTICAS PRINCIPALES:

📊 Dashboard Personalizado
- Visualiza tu membresía activa
- Consulta tus puntos acumulados
- Revisa tus asistencias del mes

💪 Rutinas de Entrenamiento
- Accede a rutinas personalizadas
- Sigue ejercicios con videos demostrativos
- Registra tu progreso

🎯 Sistema de Puntos
- Gana puntos por asistencias
- Canjea productos en la tienda
- Consulta tu historial de canjes

👥 Clases Grupales
- Consulta horarios de clases
- Inscríbete a tus clases favoritas
- Recibe notificaciones

📸 Perfil Personalizado
- Sube tu foto de perfil
- Actualiza tu información
- Consulta tu membresía

🔔 Notificaciones
- Recordatorios de membresía
- Avisos de nuevas clases
- Promociones exclusivas

📱 Fácil de Usar
- Interfaz intuitiva y moderna
- Diseño responsive
- Modo oscuro

Descarga ahora y comienza tu transformación con Megalife Gym!
```

---

### **PASO 8: Publicar en Play Console**

1. Ve a [Google Play Console](https://play.google.com/console)
2. Crea una nueva aplicación
3. Completa la información:
   - Nombre de la app
   - Categoría: Salud y bienestar
   - Idioma predeterminado: Español
4. Sube el AAB
5. Completa el cuestionario de contenido
6. Configura la clasificación de contenido
7. Establece países de distribución
8. Configura precios (Gratis)
9. Envía para revisión

---

## 🔧 COMANDOS RÁPIDOS

### Desarrollo
```bash
# Ejecutar en modo debug
flutter run

# Hot reload
r

# Hot restart
R
```

### Release
```bash
# Limpiar
flutter clean

# Generar AAB
flutter build appbundle --release

# Generar APK
flutter build apk --release

# Instalar release
flutter install --release
```

---

## ✅ CHECKLIST FINAL

Antes de publicar, verifica:

- [ ] Keystore generado y guardado en lugar seguro
- [ ] `key.properties` creado y en `.gitignore`
- [ ] `applicationId` cambiado a único
- [ ] Versión actualizada en `pubspec.yaml`
- [ ] Iconos de la app reemplazados
- [ ] Permisos correctos en AndroidManifest
- [ ] AAB generado sin errores
- [ ] App probada en modo release
- [ ] Capturas de pantalla tomadas
- [ ] Descripción preparada
- [ ] Cuenta de Play Console creada
- [ ] Política de privacidad preparada (si aplica)

---

## 📞 SOPORTE

Si encuentras algún problema:
1. Revisa los logs: `flutter logs`
2. Verifica la configuración de firma
3. Asegúrate de que todas las dependencias estén actualizadas
4. Limpia el proyecto: `flutter clean && flutter pub get`

---

## 🎉 ¡LISTO!

Tu app está lista para ser publicada en la Play Store.

**Tiempo estimado de revisión:** 1-3 días hábiles
