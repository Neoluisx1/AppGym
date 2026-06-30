# 🚀 Configuración para Producción - Gym App

## ✅ Nueva Funcionalidad Implementada

La app ahora incluye un **sistema de configuración dinámica** que te permite:

1. ✅ **Configurar la URL del servidor** desde la app (sin recompilar)
2. ✅ **Protección con contraseña** para acceso a configuración
3. ✅ **Soporte para múltiples entornos** (desarrollo, producción, local)
4. ✅ **Cambio de configuración en tiempo real**

---

## 🎯 Cómo Usar la Configuración

### 1️⃣ Acceder a la Configuración

Cuando la app inicie (pantalla de splash):

1. Verás un **ícono de configuración** ⚙️ en la esquina superior derecha
2. Toca el ícono para acceder a la pantalla de configuración
3. Se te pedirá una **contraseña de administrador**

**Contraseña por defecto**: `admin123`

### 2️⃣ Configurar URL del Servidor

Una vez autenticado:

1. Verás un campo para **"URL del Servidor"**
2. Ingresa la URL de tu backend (ejemplos abajo)
3. Presiona **"Guardar"**
4. La app se reiniciará automáticamente con la nueva configuración

### 3️⃣ Ejemplos de URLs

| Entorno | URL Ejemplo |
|---------|-------------|
| **Producción** | `https://tu-dominio.com` |
| **Servidor Local (Red)** | `http://192.168.0.213:8000` |
| **Emulador Android** | `http://10.0.2.2:8000` |
| **Localhost (iOS)** | `http://localhost:8000` |

**Nota**: No necesitas agregar `/api/v1` al final, la app lo hace automáticamente.

---

## 🔐 Cambiar la Contraseña de Configuración

Por seguridad, debes cambiar la contraseña por defecto antes de distribución:

### Opción A - Desde el Código (Antes de Compilar)

Edita el archivo: `lib/providers/settings_provider.dart`

```dart
static const String _defaultPassword = 'admin123'; // 👈 Cambia esto
```

Recompila la app con tu nueva contraseña.

### Opción B - Crear Funcionalidad de Cambio (Futuro)

Puedes implementar una pantalla adicional que permita cambiar la contraseña usando el método:

```dart
settingsProvider.changeConfigPassword(currentPassword, newPassword);
```

---

## 📱 Preparar para Producción

### Paso 1: Configurar URL de Producción

Antes de compilar la versión final:

1. Edita: `lib/providers/settings_provider.dart`
2. Cambia la URL por defecto:

```dart
static const String _defaultUrl = 'https://tu-dominio.com/api/v1';
```

### Paso 2: Cambiar Contraseña por Defecto

```dart
static const String _defaultPassword = 'TU_CONTRASEÑA_SEGURA';
```

### Paso 3: Deshabilitar Debug Logs (Opcional)

En `lib/core/services/api_service.dart`, comenta o elimina el interceptor de logs:

```dart
// // Interceptor para logs (solo en debug)
// _dio.interceptors.add(
//   LogInterceptor(
//     requestBody: true,
//     responseBody: true,
//     error: true,
//   ),
// );
```

### Paso 4: Compilar APK de Producción

```cmd
flutter build apk --release
```

O para App Bundle (Google Play):

```cmd
flutter build appbundle --release
```

El archivo estará en:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

## 🌐 Configurar Tu Servidor Backend

### Requisitos del Servidor:

1. **HTTPS** (certificado SSL)
2. **CORS** configurado para permitir requests de la app
3. **API accesible** en `/api/v1`

### Configuración Laravel (ejemplo):

En `config/cors.php`:

```php
'paths' => ['api/*'],
'allowed_origins' => ['*'], // En producción, especifica tus dominios
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

En `.env`:

```env
APP_URL=https://tu-dominio.com
```

---

## 🔧 Características del Sistema de Configuración

### 1. Almacenamiento Persistente

La configuración se guarda usando `SharedPreferences`:
- ✅ Persiste entre reinicios de la app
- ✅ No requiere permisos especiales
- ✅ Fácil de resetear si es necesario

### 2. Validación Automática

El sistema valida:
- ✅ URL debe comenzar con `http://` o `https://`
- ✅ Agrega automáticamente `/api/v1` si falta
- ✅ Limpia espacios y barras al final

### 3. Indicador Visual

En la pantalla de splash:
- 🟢 **Verde**: URL personalizada configurada
- ⚪ **Gris**: Usando URL por defecto

---

## 📝 Flujo de Usuario Final

1. Usuario descarga la app de Play Store/App Store
2. Primera vez: usa la URL por defecto que configuraste
3. Si necesita cambiar servidor:
   - Toca ⚙️ en pantalla de inicio
   - Ingresa contraseña de admin
   - Configura nueva URL
   - Guarda y la app se conecta al nuevo servidor

---

## 🛠️ Troubleshooting

### "No puedo acceder a la configuración"

- Verifica la contraseña por defecto: `admin123`
- Si la cambiaste, usa la nueva contraseña

### "Error al guardar configuración"

- Verifica que la URL sea válida
- Debe comenzar con `http://` o `https://`

### "Connection refused" después de configurar

- Verifica que el servidor esté en línea
- Prueba la URL en un navegador
- Asegúrate que el servidor permita CORS

---

## 🎉 Ventajas de Este Sistema

✅ **No requiere recompilar** para cambiar servidor  
✅ **Seguro** con protección por contraseña  
✅ **Flexible** soporta desarrollo, staging y producción  
✅ **Fácil de usar** interfaz intuitiva  
✅ **Visual** muestra la URL actual en todo momento  

---

## 📞 Próximos Pasos Sugeridos

1. ✅ **Agregar pantalla de cambio de contraseña** (opcional)
2. ✅ **Validar conectividad** antes de guardar URL (ping al servidor)
3. ✅ **Múltiples perfiles** (dev, staging, production)
4. ✅ **Exportar/Importar** configuración vía QR code

---

**¡Tu app ahora está lista para producción con configuración dinámica!** 🚀
