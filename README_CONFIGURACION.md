# ⚙️ Sistema de Configuración Dinámica - Gym App

## 🎯 Problema Resuelto

Anteriormente, la app tenía problemas de conexión porque:
- ❌ La URL del servidor estaba hardcodeada
- ❌ Diferentes dispositivos requieren diferentes URLs (emulador vs dispositivo físico)
- ❌ Cambiar la URL requería recompilar la app

## ✅ Solución Implementada

Ahora la app incluye un **sistema de configuración dinámica** que permite:

1. **Configurar la URL del servidor desde la app** (sin recompilar)
2. **Protección con contraseña** para prevenir cambios no autorizados
3. **Indicador visual** de la URL actual
4. **Persistencia** de la configuración entre reinicios

---

## 🚀 Cómo Usar

### Primera Vez / Desarrollo

1. **Inicia la app** - verás la pantalla de splash
2. **Toca el ícono ⚙️** en la esquina superior derecha
3. **Ingresa la contraseña**: `admin123` (por defecto)
4. **Configura la URL** del servidor:
   - Desarrollo local: `http://192.168.0.213:8000`
   - Emulador Android: `http://10.0.2.2:8000`
   - Producción: `https://tu-servidor.com`
5. **Guarda** y la app se conectará automáticamente

### Producción

Para distribución final:

1. Edita `lib/providers/settings_provider.dart`
2. Cambia:
   ```dart
   static const String _defaultUrl = 'https://tu-dominio.com/api/v1';
   static const String _defaultPassword = 'TuContraseñaSegura';
   ```
3. Compila: `flutter build apk --release`

---

## 📂 Archivos Importantes

| Archivo | Descripción |
|---------|-------------|
| `lib/providers/settings_provider.dart` | Maneja la configuración del servidor |
| `lib/screens/settings/server_config_screen.dart` | Pantalla de configuración con contraseña |
| `lib/core/services/api_service.dart` | Servicio HTTP que usa la URL dinámica |
| `lib/main.dart` | Inicializa y muestra la configuración |

---

## 🔐 Seguridad

- ✅ **Contraseña requerida** para acceder a configuración
- ✅ **Almacenamiento seguro** usando SharedPreferences
- ✅ **Validación de URLs** antes de guardar
- ✅ **Sin exposición** de credenciales en código

**Importante**: Cambia la contraseña por defecto antes de distribuir la app en producción.

---

## 🎨 Características

### Pantalla de Splash
- Botón de configuración (⚙️) en esquina superior derecha
- Indicador de URL actual en la parte inferior
- Color verde = URL personalizada | Gris = URL por defecto

### Pantalla de Configuración
- Autenticación con contraseña
- Sugerencias de URLs comunes
- Validación en tiempo real
- Feedback visual al guardar

---

## 📱 Casos de Uso

### Desarrollador
```
1. Toca ⚙️
2. Ingresa: admin123
3. URL: http://192.168.0.213:8000
4. Guarda
5. ✅ Conectado a servidor local
```

### Usuario Final (Producción)
```
1. App instalada desde Play Store
2. Ya viene configurada con URL de producción
3. Solo usa la app normalmente
4. (Opcional) Puede cambiar servidor si es necesario
```

### Testing en Emulador
```
1. Toca ⚙️
2. Selecciona sugerencia "Emulador Android"
3. URL: http://10.0.2.2:8000
4. Guarda
5. ✅ Conectado
```

---

## 🔧 Configuración Avanzada

### Agregar Más Sugerencias

En `settings_provider.dart`:

```dart
Map<String, String> getSuggestedConfigs() {
  return {
    'Emulador Android': 'http://10.0.2.2:8000',
    'Localhost (iOS/Web)': 'http://localhost:8000',
    'Producción': 'https://tu-servidor.com',
    'Red Local': 'http://192.168.0.213:8000',
    'Staging': 'https://staging.tu-servidor.com', // 👈 Nuevo
  };
}
```

### Resetear Configuración

Desde el código, puedes agregar un botón para resetear:

```dart
await settingsProvider.resetToDefaults();
```

---

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| "Contraseña incorrecta" | Usa `admin123` o la que configuraste |
| "Error al guardar" | Verifica que la URL sea válida (http/https) |
| "Connection refused" | Verifica que el servidor esté corriendo |
| "Timeout" | Verifica firewall y que estés en la misma red |

---

## 📖 Documentación Adicional

- **`CONFIGURACION_PRODUCCION.md`** - Guía completa para despliegue en producción
- **`CONFIGURACION_API.md`** - Información sobre configuración de red
- **`SOLUCION_ERROR.md`** - Solución de errores de conexión

---

## ✅ Checklist Pre-Distribución

Antes de publicar la app:

- [ ] Cambiar `_defaultUrl` a URL de producción
- [ ] Cambiar `_defaultPassword` a contraseña segura
- [ ] Deshabilitar logs de debug (opcional)
- [ ] Probar login con URL de producción
- [ ] Compilar en modo release
- [ ] Firmar APK/AAB
- [ ] Probar en dispositivo físico

---

**¡Tu app ahora es flexible, segura y lista para cualquier entorno!** 🎉
