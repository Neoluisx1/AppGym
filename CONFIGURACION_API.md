# 🔧 Configuración de API - Gym App

## ⚠️ Problema Resuelto: Connection Refused

Si recibiste el error `Connection refused` al intentar conectarte a `http://localhost:8000`, este documento explica por qué ocurrió y cómo está solucionado.

---

## 📋 ¿Por qué ocurre este error?

Cuando ejecutas la app Flutter en un **emulador Android** o **dispositivo físico**, la palabra `localhost` se refiere al dispositivo mismo, NO a tu computadora donde está corriendo el backend.

### Soluciones por tipo de dispositivo:

| Dispositivo | URL Correcta | Explicación |
|------------|--------------|-------------|
| **Emulador Android** | `http://10.0.2.2:8000` | `10.0.2.2` es la IP especial que apunta a `localhost` de tu computadora |
| **iOS Simulator** | `http://localhost:8000` | iOS Simulator puede acceder directamente a `localhost` |
| **Dispositivo Físico** | `http://TU_IP_LOCAL:8000` | Usa la IP real de tu computadora (ej: `192.168.1.100`) |

---

## ✅ Solución Implementada

La app ahora detecta automáticamente el entorno y usa la URL correcta. Todo está configurado en:

📁 **`lib/core/constants/env_config.dart`**

---

## 🎯 Cómo Configurar el Entorno

### 1️⃣ Para Emulador (Android/iOS)

**¡No necesitas hacer nada!** El entorno por defecto ya está configurado para emulador.

```dart
// En env_config.dart
static const EnvType environment = EnvType.emulator; // ✅ Por defecto
```

### 2️⃣ Para Dispositivo Físico

Si vas a probar en un celular real conectado a tu computadora:

**Paso 1:** Obtén la IP de tu computadora

**En Windows:**
```cmd
ipconfig
```
Busca `IPv4 Address` (ejemplo: `192.168.1.100`)

**En Mac/Linux:**
```bash
ifconfig
```
Busca `inet` (ejemplo: `192.168.1.100`)

**Paso 2:** Configura el archivo `env_config.dart`

```dart
// Cambiar el entorno
static const EnvType environment = EnvType.physicalDevice;

// Poner tu IP
static const String localIp = '192.168.1.100'; // 👈 Tu IP aquí
```

**Paso 3:** Asegúrate que tu celular y computadora estén en la misma red WiFi

### 3️⃣ Para Producción

Cuando tengas un servidor en producción:

```dart
// Cambiar el entorno
static const EnvType environment = EnvType.production;

// Configurar la URL de producción
static const String productionUrl = 'https://tu-servidor.com/api/v1';
```

---

## 🚀 Verificar la Configuración

Cuando inicies la app en modo debug, verás en la consola:

```
╔════════════════════════════════════════╗
║         GYM APP - CONFIGURACIÓN        ║
╠════════════════════════════════════════╣
║ Entorno: Emulador                      ║
║ API URL: http://10.0.2.2:8000/api/v1  ║
╚════════════════════════════════════════╝
```

Esto te confirma que la app está usando la URL correcta.

---

## 🔥 Pasos para Ejecutar la App

### 1. Inicia el Backend

Asegúrate que tu backend Laravel esté corriendo:

```bash
cd /ruta/al/backend
php artisan serve
```

Debería mostrar: `Server running on [http://127.0.0.1:8000]`

### 2. Ejecuta la App Flutter

**Opción A - Con el script:**
```cmd
EJECUTAR_APP.bat
```

**Opción B - Manual:**
```cmd
flutter run
```

### 3. Verifica la Conexión

- Revisa los logs en la consola
- Debería mostrar la configuración del entorno
- Intenta hacer login
- Si ves `Connection refused`, verifica:
  - ✅ Backend está corriendo
  - ✅ Configuración del entorno es correcta
  - ✅ IP es correcta (si usas dispositivo físico)
  - ✅ Ambos dispositivos están en la misma red

---

## 📝 Notas Adicionales

### Firewall de Windows

Si usas dispositivo físico y no funciona, el firewall podría estar bloqueando las conexiones. Agrega una excepción para PHP:

1. Busca "Windows Defender Firewall"
2. Click en "Allow an app through firewall"
3. Busca PHP y marca las casillas de red privada y pública

### Cambiar Puerto

Si tu backend corre en un puerto diferente (ej: 8080), actualiza en `env_config.dart`:

```dart
// Para emulador Android
return 'http://10.0.2.2:8080/api/v1';

// Para dispositivo físico
return 'http://$localIp:8080/api/v1';
```

---

## 🐛 Troubleshooting

| Error | Solución |
|-------|----------|
| `Connection refused` | Verifica que el backend esté corriendo |
| `Timeout` | Verifica la IP y que estés en la misma red |
| `Network unreachable` | Verifica tu conexión a internet/WiFi |
| `401 Unauthorized` | El login es incorrecto, pero la conexión funciona ✅ |

---

## 📞 Soporte

Si sigues teniendo problemas:

1. Revisa los logs completos en la consola
2. Verifica la configuración en `env_config.dart`
3. Asegúrate que el backend responda con: `curl http://localhost:8000/api/v1/auth/login`

---

**¡Listo!** Ahora tu app debería conectarse correctamente al backend. 🎉
