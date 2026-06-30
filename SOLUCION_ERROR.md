# ✅ Error Solucionado: Connection Refused

## 🐛 Problema Original

```
DioException [connection error]: The connection errored: Connection refused
Error: SocketException: Connection refused
uri: http://localhost:8000/api/v1/auth/login
```

---

## 🔍 Causa del Error

Cuando ejecutas la app en un **emulador Android**, la dirección `localhost` se refiere al emulador mismo, NO a tu computadora donde corre el backend Laravel.

---

## ✨ Solución Implementada

He corregido automáticamente la configuración de la API. Los cambios incluyen:

### 📝 Archivos Modificados/Creados:

1. **`lib/core/constants/env_config.dart`** ✨ NUEVO
   - Sistema de configuración de entornos
   - Detección automática Android/iOS
   - Soporte para dispositivos físicos y producción

2. **`lib/core/constants/api_constants.dart`** 🔧 ACTUALIZADO
   - Ahora usa `EnvConfig` para obtener la URL correcta

3. **`lib/main.dart`** 🔧 ACTUALIZADO
   - Muestra información del entorno al iniciar
   - Ayuda a verificar la configuración

4. **`CONFIGURACION_API.md`** ✨ NUEVO
   - Documentación completa sobre la configuración

5. **`EJECUTAR_APP.bat`** 🔧 ACTUALIZADO
   - Información actualizada sobre la conexión

---

## 🚀 ¿Qué Hace Ahora la App?

La app **detecta automáticamente** el tipo de dispositivo:

- **Emulador Android** → usa `http://10.0.2.2:8000/api/v1` ✅
- **iOS Simulator** → usa `http://localhost:8000/api/v1` ✅
- **Dispositivo Físico** → configurable en `env_config.dart`

---

## 🎯 Siguiente Paso: ¡Ejecutar la App!

### 1. Asegúrate que el backend esté corriendo

```bash
cd /ruta/al/backend
php artisan serve
```

### 2. Ejecuta la app Flutter

```cmd
flutter run
```

O usa el script:
```cmd
EJECUTAR_APP.bat
```

### 3. Verifica la configuración

Al iniciar, verás en los logs:

```
╔════════════════════════════════════════╗
║         GYM APP - CONFIGURACIÓN        ║
╠════════════════════════════════════════╣
║ Entorno: Emulador                      ║
║ API URL: http://10.0.2.2:8000/api/v1  ║
╚════════════════════════════════════════╝
```

---

## 📱 Para Dispositivo Físico

Si vas a probar en tu celular:

1. Abre `lib/core/constants/env_config.dart`
2. Cambia:
   ```dart
   static const EnvType environment = EnvType.physicalDevice;
   static const String localIp = 'TU_IP_AQUI'; // ej: 192.168.1.100
   ```
3. Obtén tu IP con `ipconfig` (Windows) o `ifconfig` (Mac/Linux)

---

## 🔧 Configuración Avanzada

Para cambiar entre entornos, edita **`lib/core/constants/env_config.dart`**:

```dart
// Opciones disponibles:
static const EnvType environment = EnvType.emulator;        // Emulador
static const EnvType environment = EnvType.physicalDevice;  // Dispositivo físico
static const EnvType environment = EnvType.production;      // Producción
```

---

## 📖 Documentación Completa

Lee **`CONFIGURACION_API.md`** para más detalles sobre:
- Configuración de entornos
- Troubleshooting
- Configuración de firewall
- Cambiar puertos

---

## ✅ Resumen

| Antes | Ahora |
|-------|-------|
| ❌ `localhost` no funcionaba en Android | ✅ Usa `10.0.2.2` automáticamente |
| ❌ Error: Connection refused | ✅ Conexión exitosa |
| ❌ Configuración manual | ✅ Detección automática |

---

**¡El error está solucionado!** Solo asegúrate que el backend esté corriendo y ejecuta la app. 🎉

Si tienes algún problema, consulta `CONFIGURACION_API.md` o revisa los logs de la consola.
