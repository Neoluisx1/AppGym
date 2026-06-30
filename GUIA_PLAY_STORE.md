# 📱 GUÍA COMPLETA - PUBLICAR EN PLAY STORE

## ✅ CONFIGURACIÓN COMPLETADA

La app ya está configurada para Play Store con:

- ✅ **Application ID**: `com.megalifegym.app`
- ✅ **Versión**: 1.0.0 (versionCode: 1)
- ✅ **minSdk**: 21 (Android 5.0+)
- ✅ **targetSdk**: 34 (Android 14)
- ✅ **Nombre**: Megalife Gym
- ✅ **Descripción**: App móvil para gestión de membresías, asistencias y tienda

---

## 📋 PASOS PARA PUBLICAR

### 1️⃣ GENERAR KEYSTORE (Solo la primera vez)

```bash
# Ejecuta este script:
GENERAR_KEYSTORE.bat
```

**Datos que te pedirá:**
- Contraseña del keystore (mínimo 6 caracteres)
- Nombre y apellido
- Unidad organizativa (ej: Desarrollo)
- Organización (ej: Megalife Gym)
- Ciudad
- Estado/Provincia
- Código de país (ej: PE para Perú)

**⚠️ IMPORTANTE:** 
- Guarda bien la contraseña, la necesitarás para actualizar la app
- El archivo `upload-keystore.jks` se guardará en `android/app/`
- **NUNCA** compartas este archivo ni lo subas a Git

---

### 2️⃣ CONFIGURAR key.properties

1. Copia el archivo `android/key.properties.example` a `android/key.properties`
2. Edita `android/key.properties` con tus datos:

```properties
storePassword=TU_PASSWORD_DEL_KEYSTORE
keyPassword=TU_PASSWORD_DEL_KEYSTORE
keyAlias=upload
storeFile=C:/xampp/htdocs/gym_app/gym_app/android/app/upload-keystore.jks
```

**⚠️ IMPORTANTE:** 
- Agrega `key.properties` al `.gitignore` para no subirlo a Git
- Usa la misma contraseña que ingresaste al generar el keystore

---

### 3️⃣ GENERAR APK/AAB FIRMADO

```bash
# Ejecuta este script:
GENERAR_RELEASE_PLAYSTORE.bat
```

**Opciones disponibles:**
1. **APK** - Para instalar directamente en dispositivos (pruebas)
2. **AAB** - Para subir a Play Store ⭐ RECOMENDADO
3. **Ambos** - Genera APK y AAB

**Ubicación de los archivos generados:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

### 4️⃣ PREPARAR RECURSOS PARA PLAY STORE

Necesitarás crear los siguientes recursos gráficos:

#### 📱 Icono de la App
- **Tamaño**: 512x512 px
- **Formato**: PNG (32-bit)
- **Sin transparencia**

#### 🖼️ Feature Graphic (Banner)
- **Tamaño**: 1024x500 px
- **Formato**: PNG o JPG

#### 📸 Screenshots (Capturas de pantalla)
- **Mínimo**: 2 capturas
- **Recomendado**: 4-8 capturas
- **Tamaños aceptados**:
  - Teléfono: 320-3840 px (ancho o alto)
  - Tablet 7": 600-7680 px
  - Tablet 10": 1280-7680 px

**Pantallas sugeridas para capturar:**
1. Dashboard principal
2. Perfil del usuario
3. Membresía activa
4. Tienda de productos
5. Clases grupales
6. Notificaciones

---

### 5️⃣ CREAR CUENTA EN GOOGLE PLAY CONSOLE

1. Ve a [Google Play Console](https://play.google.com/console)
2. Crea una cuenta de desarrollador (costo único: $25 USD)
3. Completa la información de tu cuenta

---

### 6️⃣ CREAR NUEVA APP EN PLAY CONSOLE

1. **Crear app**
   - Nombre: Megalife Gym
   - Idioma predeterminado: Español (España)
   - Tipo: App
   - Gratis o de pago: Gratis

2. **Ficha de Play Store**
   - Nombre de la app: Megalife Gym
   - Descripción breve (80 caracteres):
     ```
     Gestiona tu membresía, asistencias y compra productos del gym
     ```
   - Descripción completa (4000 caracteres):
     ```
     Megalife Gym es la aplicación oficial para miembros del gimnasio.
     
     CARACTERÍSTICAS PRINCIPALES:
     
     📊 Dashboard Personalizado
     - Ve tu membresía activa y días restantes
     - Consulta tus asistencias del mes
     - Revisa tus puntos acumulados
     
     💪 Gestión de Membresía
     - Información completa de tu plan
     - Fechas de inicio y vencimiento
     - Estado de tu membresía
     
     🛒 Tienda Integrada
     - Compra productos y suplementos
     - Canjea puntos por productos
     - Historial de compras
     
     👤 Perfil Personal
     - Actualiza tu información
     - Sube tu foto de perfil
     - Cambia tu contraseña
     
     🔔 Notificaciones
     - Alertas de vencimiento de membresía
     - Promociones especiales
     - Noticias del gym
     
     📅 Clases Grupales
     - Consulta horarios de clases
     - Inscríbete a clases
     - Ve cupos disponibles
     
     ⭐ Sistema de Puntos
     - Acumula puntos por tus pagos
     - Canjea puntos por productos
     - Consulta tu saldo de puntos
     
     Descarga la app y lleva el control total de tu experiencia en Megalife Gym.
     ```

3. **Recursos gráficos**
   - Sube el icono (512x512)
   - Sube el feature graphic (1024x500)
   - Sube las capturas de pantalla

4. **Categorización**
   - Categoría: Salud y bienestar
   - Etiquetas: gimnasio, fitness, salud, membresía

5. **Información de contacto**
   - Email: tu_email@megalifegym.com
   - Sitio web: https://megalifegym.com
   - Teléfono: (opcional)

6. **Política de privacidad**
   - URL: https://megalifegym.com/privacy (debes crear esta página)

---

### 7️⃣ CONFIGURAR VERSIÓN DE PRODUCCIÓN

1. **Producción** → **Crear nueva versión**
2. **Subir AAB**: Sube el archivo `app-release.aab`
3. **Nombre de la versión**: 1.0.0 (1)
4. **Notas de la versión**:
   ```
   Versión inicial de Megalife Gym
   
   - Dashboard con información de membresía
   - Gestión de perfil personal
   - Tienda de productos integrada
   - Sistema de puntos y canjes
   - Notificaciones de membresía
   - Consulta de clases grupales
   ```

---

### 8️⃣ COMPLETAR CUESTIONARIO DE CONTENIDO

1. **Clasificación de contenido**
   - Responde el cuestionario
   - Para app de gym: generalmente es "Para todos"

2. **Público objetivo**
   - Edad: 13+ (o según tu política)

3. **Anuncios**
   - ¿Contiene anuncios?: No

---

### 9️⃣ CONFIGURAR PRECIOS Y DISTRIBUCIÓN

1. **Países disponibles**: Selecciona los países donde estará disponible
2. **Precio**: Gratis
3. **Distribución**: Google Play

---

### 🔟 ENVIAR A REVISIÓN

1. Revisa que todo esté completo (✓ verde en todas las secciones)
2. Click en **"Enviar a revisión"**
3. Espera la aprobación (puede tomar 1-7 días)

---

## 🔄 ACTUALIZAR LA APP (Versiones futuras)

### Incrementar versión

Edita `pubspec.yaml`:
```yaml
version: 1.0.1+2  # 1.0.1 es versionName, 2 es versionCode
```

Edita `android/app/build.gradle.kts`:
```kotlin
versionCode = 2
versionName = "1.0.1"
```

### Generar nuevo AAB

```bash
GENERAR_RELEASE_PLAYSTORE.bat
```

### Subir a Play Console

1. **Producción** → **Crear nueva versión**
2. Sube el nuevo AAB
3. Agrega notas de la versión
4. **Enviar a revisión**

---

## 📝 CHECKLIST FINAL

Antes de publicar, verifica:

- [ ] Keystore generado y guardado en lugar seguro
- [ ] key.properties configurado correctamente
- [ ] AAB generado sin errores
- [ ] Icono de 512x512 creado
- [ ] Feature graphic de 1024x500 creado
- [ ] Mínimo 2 capturas de pantalla
- [ ] Descripción completa y atractiva
- [ ] Política de privacidad publicada
- [ ] Información de contacto correcta
- [ ] Categoría y etiquetas apropiadas
- [ ] Cuestionario de contenido completado
- [ ] Países de distribución seleccionados
- [ ] Todo marcado en verde en Play Console

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "keystore not found"
- Verifica que ejecutaste `GENERAR_KEYSTORE.bat`
- Verifica la ruta en `key.properties`

### Error: "signing config not found"
- Verifica que `key.properties` existe en `android/`
- Verifica que las contraseñas son correctas

### Error de compilación
- Ejecuta `flutter clean`
- Ejecuta `flutter pub get`
- Intenta nuevamente

### App rechazada por Google
- Lee el motivo del rechazo en Play Console
- Corrige el problema
- Incrementa versionCode
- Vuelve a enviar

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa esta guía completa
2. Consulta la [documentación oficial de Flutter](https://docs.flutter.dev/deployment/android)
3. Revisa [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

## 🎉 ¡LISTO!

Tu app está configurada y lista para ser publicada en Play Store.

**Archivos importantes creados:**
- `GENERAR_KEYSTORE.bat` - Genera el keystore
- `GENERAR_RELEASE_PLAYSTORE.bat` - Genera APK/AAB firmado
- `android/key.properties.example` - Plantilla de configuración
- `GUIA_PLAY_STORE.md` - Esta guía

**Próximos pasos:**
1. Ejecuta `GENERAR_KEYSTORE.bat`
2. Configura `key.properties`
3. Ejecuta `GENERAR_RELEASE_PLAYSTORE.bat`
4. Sube el AAB a Play Console

¡Éxito con tu publicación! 🚀
