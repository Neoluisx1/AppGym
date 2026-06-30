# 📋 Guía de Implementación del Backend

Esta guía detalla los endpoints que necesitas implementar en el backend Laravel para que funcionen todas las nuevas características de la app.

## 🔔 Sistema de Notificaciones

### 1. Crear Tabla de Notificaciones

```sql
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('membership_expiring', 'membership_expired', 'group_class', 'routine', 'goal', 'announcement') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    data JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 2. Endpoints de Notificaciones

#### GET `/api/v1/client/notifications`
**Descripción**: Obtener todas las notificaciones del usuario

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Membresía por vencer",
      "message": "Tu membresía vence en 5 días. Renuévala ahora.",
      "type": "membership_expiring",
      "is_read": false,
      "data": {
        "membership_id": 1,
        "days_remaining": 5
      },
      "created_at": "2025-12-24T10:00:00.000000Z"
    },
    {
      "id": 2,
      "title": "Nueva clase grupal",
      "message": "Yoga para principiantes - Lunes 6:00 PM",
      "type": "group_class",
      "is_read": true,
      "data": {
        "class_id": 5
      },
      "created_at": "2025-12-23T15:30:00.000000Z"
    }
  ]
}
```

#### POST `/api/v1/client/notifications/{id}/read`
**Descripción**: Marcar una notificación como leída

**Response**:
```json
{
  "success": true,
  "message": "Notificación marcada como leída"
}
```

#### POST `/api/v1/client/notifications/read-all`
**Descripción**: Marcar todas las notificaciones como leídas

**Response**:
```json
{
  "success": true,
  "message": "Todas las notificaciones marcadas como leídas"
}
```

#### DELETE `/api/v1/client/notifications/{id}`
**Descripción**: Eliminar una notificación

**Response**:
```json
{
  "success": true,
  "message": "Notificación eliminada"
}
```

### 3. Sistema Automático de Notificaciones

Implementar un **Command** de Laravel que se ejecute diariamente:

```php
// app/Console/Commands/SendMembershipExpirationNotifications.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Client;
use App\Models\Notification;
use Carbon\Carbon;

class SendMembershipExpirationNotifications extends Command
{
    protected $signature = 'notifications:membership-expiration';
    protected $description = 'Enviar notificaciones de vencimiento de membresías';

    public function handle()
    {
        // Notificar membresías que vencen en 7 días
        $this->notifyExpiring(7, 'Tu membresía vence en 7 días');
        
        // Notificar membresías que vencen en 3 días
        $this->notifyExpiring(3, 'Tu membresía vence en 3 días');
        
        // Notificar membresías que vencen mañana
        $this->notifyExpiring(1, 'Tu membresía vence mañana');
        
        // Notificar membresías vencidas
        $this->notifyExpired();
    }

    private function notifyExpiring($days, $message)
    {
        $targetDate = Carbon::now()->addDays($days)->format('Y-m-d');
        
        $clients = Client::whereHas('membership', function($query) use ($targetDate) {
            $query->where('end_date', $targetDate)
                  ->where('status', 'active');
        })->get();

        foreach ($clients as $client) {
            Notification::create([
                'user_id' => $client->user_id,
                'title' => 'Membresía por vencer',
                'message' => $message . '. Renuévala para seguir disfrutando de nuestros servicios.',
                'type' => 'membership_expiring',
                'data' => json_encode([
                    'membership_id' => $client->membership->id,
                    'days_remaining' => $days
                ])
            ]);
        }
    }

    private function notifyExpired()
    {
        $clients = Client::whereHas('membership', function($query) {
            $query->where('end_date', '<', Carbon::now()->format('Y-m-d'))
                  ->where('status', 'active');
        })->get();

        foreach ($clients as $client) {
            Notification::create([
                'user_id' => $client->user_id,
                'title' => 'Membresía vencida',
                'message' => 'Tu membresía ha vencido. Renuévala para continuar usando el gimnasio.',
                'type' => 'membership_expired',
                'data' => json_encode([
                    'membership_id' => $client->membership->id
                ])
            ]);
            
            // Actualizar estado de membresía
            $client->membership->update(['status' => 'expired']);
        }
    }
}
```

Registrar en `app/Console/Kernel.php`:
```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('notifications:membership-expiration')
             ->dailyAt('08:00');
}
```

## 💳 Sistema de Renovación de Membresías

### 1. Crear Tabla de Planes de Membresía

```sql
CREATE TABLE membership_plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration_days INT NOT NULL,
    type ENUM('calendar_days', 'business_days') DEFAULT 'calendar_days',
    available_days INT NULL,
    features JSON NULL,
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2. Insertar Planes de Ejemplo

```sql
INSERT INTO membership_plans (name, description, price, duration_days, type, features, is_popular) VALUES
('Básico', 'Plan mensual con acceso completo al gimnasio', 299.00, 30, 'calendar_days', 
 '["Acceso completo al gimnasio", "Uso de equipos", "Duchas y vestidores"]', false),

('Premium', 'Plan trimestral con beneficios adicionales', 799.00, 90, 'calendar_days',
 '["Acceso completo al gimnasio", "Clases grupales ilimitadas", "Asesoría nutricional", "Descuentos en productos"]', true),

('Días Hábiles', 'Plan flexible de 12 días hábiles', 250.00, 90, 'business_days',
 '["12 días hábiles de acceso", "Válido por 90 días", "Ideal para uso ocasional"]', false);
```

### 3. Endpoints de Membresías

#### GET `/api/v1/membership-plans`
**Descripción**: Obtener todos los planes de membresía disponibles

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Básico",
      "description": "Plan mensual con acceso completo al gimnasio",
      "price": "299.00",
      "duration_days": 30,
      "type": "calendar_days",
      "available_days": null,
      "features": [
        "Acceso completo al gimnasio",
        "Uso de equipos",
        "Duchas y vestidores"
      ],
      "is_popular": false
    },
    {
      "id": 2,
      "name": "Premium",
      "description": "Plan trimestral con beneficios adicionales",
      "price": "799.00",
      "duration_days": 90,
      "type": "calendar_days",
      "available_days": null,
      "features": [
        "Acceso completo al gimnasio",
        "Clases grupales ilimitadas",
        "Asesoría nutricional",
        "Descuentos en productos"
      ],
      "is_popular": true
    }
  ]
}
```

#### POST `/api/v1/client/membership/renew`
**Descripción**: Renovar membresía del cliente

**Request**:
```json
{
  "membership_plan_id": 2
}
```

**Response**:
```json
{
  "success": true,
  "message": "Membresía renovada exitosamente",
  "data": {
    "membership": {
      "id": 1,
      "name": "Premium",
      "price": "799.00",
      "duration_days": 90,
      "start_date": "2025-12-24",
      "end_date": "2026-03-24",
      "status": "active"
    }
  }
}
```

**Implementación en Laravel**:
```php
// app/Http/Controllers/Api/V1/Client/MembershipController.php
public function renew(Request $request)
{
    $request->validate([
        'membership_plan_id' => 'required|exists:membership_plans,id'
    ]);

    $client = auth()->user()->client;
    $plan = MembershipPlan::findOrFail($request->membership_plan_id);

    // Calcular fechas
    $startDate = Carbon::now();
    $endDate = $startDate->copy()->addDays($plan->duration_days);

    // Actualizar o crear membresía
    $membership = $client->membership()->updateOrCreate(
        ['client_id' => $client->id],
        [
            'membership_plan_id' => $plan->id,
            'name' => $plan->name,
            'price' => $plan->price,
            'duration_days' => $plan->duration_days,
            'type' => $plan->type,
            'available_days' => $plan->available_days,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'status' => 'active',
            'days_used' => 0
        ]
    );

    // Crear notificación de renovación exitosa
    Notification::create([
        'user_id' => auth()->id(),
        'title' => 'Membresía renovada',
        'message' => "Tu membresía {$plan->name} ha sido renovada exitosamente hasta el {$endDate->format('d/m/Y')}.",
        'type' => 'announcement',
        'data' => json_encode(['membership_id' => $membership->id])
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Membresía renovada exitosamente',
        'data' => ['membership' => $membership]
    ]);
}
```

## 🏋️ Sistema de Clases Grupales

### 1. Crear Tablas

```sql
CREATE TABLE group_classes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    instructor VARCHAR(255),
    schedule VARCHAR(255) NOT NULL,
    capacity INT NOT NULL DEFAULT 20,
    duration INT NOT NULL DEFAULT 60,
    difficulty ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE group_class_enrollments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    group_class_id BIGINT UNSIGNED NOT NULL,
    client_id BIGINT UNSIGNED NOT NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_class_id) REFERENCES group_classes(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (group_class_id, client_id)
);
```

### 2. Insertar Clases de Ejemplo

```sql
INSERT INTO group_classes (name, description, instructor, schedule, capacity, duration, difficulty) VALUES
('Yoga Matutino', 'Sesión de yoga para comenzar el día con energía', 'María González', 'Lunes y Miércoles 7:00 AM', 15, 60, 'easy'),
('CrossFit Intenso', 'Entrenamiento de alta intensidad', 'Carlos Ruiz', 'Martes y Jueves 6:00 PM', 20, 45, 'hard'),
('Spinning', 'Clase de ciclismo indoor', 'Ana López', 'Lunes, Miércoles y Viernes 7:00 PM', 25, 50, 'medium');
```

### 3. Endpoints de Clases Grupales

#### GET `/api/v1/group-classes`
**Descripción**: Obtener todas las clases grupales

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Yoga Matutino",
      "description": "Sesión de yoga para comenzar el día con energía",
      "instructor": "María González",
      "schedule": "Lunes y Miércoles 7:00 AM",
      "capacity": 15,
      "enrolled": 8,
      "duration": 60,
      "difficulty": "easy",
      "image_url": null
    }
  ]
}
```

**Implementación**:
```php
public function index()
{
    $classes = GroupClass::where('is_active', true)
        ->withCount('enrollments as enrolled')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $classes
    ]);
}
```

#### POST `/api/v1/group-classes/{id}/enroll`
**Descripción**: Inscribirse en una clase grupal

**Response**:
```json
{
  "success": true,
  "message": "Inscripción exitosa"
}
```

**Implementación**:
```php
public function enroll($id)
{
    $class = GroupClass::findOrFail($id);
    $client = auth()->user()->client;

    // Verificar capacidad
    if ($class->enrollments()->count() >= $class->capacity) {
        return response()->json([
            'success' => false,
            'message' => 'La clase está llena'
        ], 400);
    }

    // Verificar si ya está inscrito
    if ($class->enrollments()->where('client_id', $client->id)->exists()) {
        return response()->json([
            'success' => false,
            'message' => 'Ya estás inscrito en esta clase'
        ], 400);
    }

    // Inscribir
    $class->enrollments()->create([
        'client_id' => $client->id
    ]);

    // Crear notificación
    Notification::create([
        'user_id' => auth()->id(),
        'title' => 'Inscripción exitosa',
        'message' => "Te has inscrito en {$class->name} - {$class->schedule}",
        'type' => 'group_class',
        'data' => json_encode(['class_id' => $class->id])
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Inscripción exitosa'
    ]);
}
```

## 📊 Actualizar Dashboard para Incluir Puntos

Asegúrate de que el endpoint del dashboard incluya los puntos del cliente:

```php
// app/Http/Controllers/Api/V1/Client/DashboardController.php
public function index()
{
    $client = auth()->user()->client;

    return response()->json([
        'success' => true,
        'data' => [
            'client' => [
                'name' => auth()->user()->name,
                'email' => auth()->user()->email,
                'points' => $client->points, // ← IMPORTANTE
                'photo_url' => auth()->user()->profile_photo_url
            ],
            'membership' => $client->membership,
            'stats' => [
                'total_attendances' => $client->attendances()->count(),
                'this_month_attendances' => $client->attendances()
                    ->whereMonth('date', now()->month)->count(),
                'active_routines' => $client->routines()->count(),
                'active_goals' => $client->goals()->where('status', 'in_progress')->count(),
            ],
            // ... resto de datos
        ]
    ]);
}
```

## 🛍️ Sistema de Tienda (Store)

### 1. Crear Tablas de Productos y Canjes

```sql
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) DEFAULT 0.00,
    points_price INT NOT NULL,
    image_url VARCHAR(500),
    category VARCHAR(100) DEFAULT 'general',
    stock INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE redemptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    points_used INT NOT NULL,
    status ENUM('pending', 'claimed', 'cancelled') DEFAULT 'pending',
    redeemed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    claimed_at TIMESTAMP NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

### 2. Insertar Productos de Ejemplo

```sql
INSERT INTO products (name, description, price, points_price, category, stock, is_featured) VALUES
('Proteína Whey 1kg', 'Proteína de suero de leche de alta calidad', 250.00, 500, 'suplementos', 20, true),
('Shaker Deportivo', 'Vaso mezclador con compartimentos', 50.00, 100, 'accesorios', 50, false),
('Toalla Gym', 'Toalla de microfibra absorbente', 80.00, 150, 'accesorios', 30, false),
('Guantes de Entrenamiento', 'Guantes acolchados para levantamiento', 120.00, 250, 'accesorios', 15, true),
('Creatina 300g', 'Creatina monohidratada pura', 150.00, 300, 'suplementos', 25, false),
('Camiseta Gym', 'Camiseta deportiva dry-fit', 100.00, 200, 'ropa', 40, true),
('Botella de Agua 1L', 'Botella deportiva con medidor', 60.00, 120, 'accesorios', 60, false);
```

### 3. Endpoints de Tienda

#### GET `/api/v1/store/products`
**Descripción**: Obtener todos los productos disponibles

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Proteína Whey 1kg",
      "description": "Proteína de suero de leche de alta calidad",
      "price": "250.00",
      "points_price": 500,
      "image_url": null,
      "category": "suplementos",
      "stock": 20,
      "is_active": true,
      "is_featured": true
    }
  ]
}
```

**Implementación**:
```php
// app/Http/Controllers/Api/V1/StoreController.php
public function index()
{
    $products = Product::where('is_active', true)
        ->orderBy('is_featured', 'desc')
        ->orderBy('name')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $products
    ]);
}
```

#### POST `/api/v1/store/products/{id}/redeem`
**Descripción**: Canjear un producto con puntos

**Response**:
```json
{
  "success": true,
  "message": "Producto canjeado exitosamente",
  "data": {
    "redemption": {
      "id": 1,
      "product_name": "Proteína Whey 1kg",
      "points_used": 500,
      "status": "pending",
      "redeemed_at": "2025-12-24T16:30:00.000000Z"
    },
    "remaining_points": 250
  }
}
```

**Implementación**:
```php
public function redeem($productId)
{
    $product = Product::findOrFail($productId);
    $client = auth()->user()->client;

    // Validar stock
    if ($product->stock <= 0) {
        return response()->json([
            'success' => false,
            'message' => 'Producto agotado'
        ], 400);
    }

    // Validar puntos
    if ($client->points < $product->points_price) {
        return response()->json([
            'success' => false,
            'message' => 'Puntos insuficientes'
        ], 400);
    }

    DB::beginTransaction();
    try {
        // Crear canje
        $redemption = Redemption::create([
            'client_id' => $client->id,
            'product_id' => $product->id,
            'product_name' => $product->name,
            'points_used' => $product->points_price,
            'status' => 'pending'
        ]);

        // Descontar puntos
        $client->decrement('points', $product->points_price);

        // Reducir stock
        $product->decrement('stock');

        // Crear notificación
        Notification::create([
            'user_id' => auth()->id(),
            'title' => 'Producto canjeado',
            'message' => "Has canjeado {$product->name}. Recógelo en recepción.",
            'type' => 'announcement',
            'data' => json_encode(['redemption_id' => $redemption->id])
        ]);

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Producto canjeado exitosamente',
            'data' => [
                'redemption' => $redemption,
                'remaining_points' => $client->fresh()->points
            ]
        ]);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => 'Error al canjear producto'
        ], 500);
    }
}
```

#### GET `/api/v1/client/redemptions`
**Descripción**: Obtener canjes del cliente

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "product_id": 1,
      "product_name": "Proteína Whey 1kg",
      "points_used": 500,
      "status": "pending",
      "redeemed_at": "2025-12-24T16:30:00.000000Z",
      "claimed_at": null
    }
  ]
}
```

**Implementación**:
```php
public function myRedemptions()
{
    $client = auth()->user()->client;
    
    $redemptions = Redemption::where('client_id', $client->id)
        ->orderBy('redeemed_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $redemptions
    ]);
}
```

## 🔄 Resumen de Rutas a Agregar

```php
// routes/api.php

Route::middleware(['auth:sanctum'])->prefix('v1')->group(function () {
    
    // Notificaciones
    Route::prefix('client/notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::post('/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::delete('/{id}', [NotificationController::class, 'destroy']);
    });
    
    // Membresías
    Route::get('/membership-plans', [MembershipPlanController::class, 'index']);
    Route::post('/client/membership/renew', [MembershipController::class, 'renew']);
    
    // Clases Grupales
    Route::get('/group-classes', [GroupClassController::class, 'index']);
    Route::post('/group-classes/{id}/enroll', [GroupClassController::class, 'enroll']);
    
    // Tienda
    Route::prefix('store')->group(function () {
        Route::get('/products', [StoreController::class, 'index']);
        Route::post('/products/{id}/redeem', [StoreController::class, 'redeem']);
        Route::post('/products/{id}/buy', [StoreController::class, 'buy']);
    });
    
    Route::get('/client/redemptions', [StoreController::class, 'myRedemptions']);
});
```

## 🎯 Sistema de Metas Asignadas por Entrenadores

### 1. Actualizar Tabla de Goals

```sql
ALTER TABLE goals ADD COLUMN assigned_by VARCHAR(255) NULL AFTER status;
ALTER TABLE goals MODIFY COLUMN status ENUM('pending', 'accepted', 'in_progress', 'completed', 'rejected') DEFAULT 'in_progress';
```

**Estados de las metas:**
- `pending`: Meta asignada por el entrenador, esperando aceptación del cliente
- `accepted` / `in_progress`: Meta aceptada por el cliente, en progreso
- `completed`: Meta completada
- `rejected`: Meta rechazada por el cliente

### 2. Endpoints de Gestión de Metas

#### POST `/api/v1/client/goals/{id}/accept`
**Descripción**: Cliente acepta una meta asignada por el entrenador

**Response**:
```json
{
  "success": true,
  "message": "Meta aceptada exitosamente"
}
```

**Implementación**:
```php
public function acceptGoal($goalId)
{
    $goal = Goal::findOrFail($goalId);
    $client = auth()->user()->client;

    // Verificar que la meta pertenece al cliente
    if ($goal->client_id != $client->id) {
        return response()->json([
            'success' => false,
            'message' => 'No autorizado'
        ], 403);
    }

    // Verificar que está pendiente
    if ($goal->status != 'pending') {
        return response()->json([
            'success' => false,
            'message' => 'Esta meta ya fue procesada'
        ], 400);
    }

    $goal->update(['status' => 'in_progress']);

    // Crear notificación para el entrenador
    if ($goal->assigned_by) {
        Notification::create([
            'user_id' => $goal->assigned_by,
            'title' => 'Meta aceptada',
            'message' => "{$client->user->name} ha aceptado la meta: {$goal->title}",
            'type' => 'goal'
        ]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Meta aceptada exitosamente'
    ]);
}
```

#### POST `/api/v1/client/goals/{id}/reject`
**Descripción**: Cliente rechaza una meta asignada por el entrenador

**Response**:
```json
{
  "success": true,
  "message": "Meta rechazada"
}
```

**Implementación**:
```php
public function rejectGoal($goalId)
{
    $goal = Goal::findOrFail($goalId);
    $client = auth()->user()->client;

    if ($goal->client_id != $client->id) {
        return response()->json([
            'success' => false,
            'message' => 'No autorizado'
        ], 403);
    }

    if ($goal->status != 'pending') {
        return response()->json([
            'success' => false,
            'message' => 'Esta meta ya fue procesada'
        ], 400);
    }

    $goal->update(['status' => 'rejected']);

    // Notificar al entrenador
    if ($goal->assigned_by) {
        Notification::create([
            'user_id' => $goal->assigned_by,
            'title' => 'Meta rechazada',
            'message' => "{$client->user->name} ha rechazado la meta: {$goal->title}",
            'type' => 'goal'
        ]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Meta rechazada'
    ]);
}
```

### 3. Modificar Endpoint de Listado de Metas

El endpoint `GET /api/v1/client/goals` debe retornar el campo `assigned_by`:

```php
public function index()
{
    $client = auth()->user()->client;
    
    $goals = Goal::where('client_id', $client->id)
        ->whereIn('status', ['pending', 'in_progress', 'completed'])
        ->orderByRaw("FIELD(status, 'pending', 'in_progress', 'completed')")
        ->orderBy('created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $goals
    ]);
}
```

### 4. Notificación Automática de Metas Asignadas

Cuando un entrenador asigna una meta a un cliente:

```php
// En el controller del entrenador
public function assignGoal(Request $request, $clientId)
{
    $request->validate([
        'title' => 'required|string',
        'description' => 'nullable|string',
        'target_value' => 'required|numeric',
        'unit' => 'nullable|string',
        'deadline' => 'nullable|date',
        'points_reward' => 'nullable|integer'
    ]);

    $goal = Goal::create([
        'client_id' => $clientId,
        'title' => $request->title,
        'description' => $request->description,
        'target_value' => $request->target_value,
        'current_value' => 0,
        'unit' => $request->unit,
        'status' => 'pending',
        'deadline' => $request->deadline,
        'points_reward' => $request->points_reward,
        'assigned_by' => auth()->user()->name,
        'progress_percentage' => 0
    ]);

    // Notificar al cliente
    $client = Client::findOrFail($clientId);
    Notification::create([
        'user_id' => $client->user_id,
        'title' => 'Nueva meta asignada',
        'message' => "Tu entrenador te ha asignado una nueva meta: {$goal->title}",
        'type' => 'goal',
        'data' => json_encode(['goal_id' => $goal->id])
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Meta asignada exitosamente',
        'data' => $goal
    ]);
}
```

## ✅ Checklist de Implementación

- [ ] Crear tabla `notifications`
- [ ] Crear tabla `membership_plans`
- [ ] Crear tabla `group_classes`
- [ ] Crear tabla `group_class_enrollments`
- [ ] Crear tabla `products`
- [ ] Crear tabla `redemptions`
- [ ] Actualizar tabla `goals` con campo `assigned_by` y nuevos estados
- [ ] Implementar endpoints de notificaciones
- [ ] Implementar endpoints de membresías
- [ ] Implementar endpoints de clases grupales
- [ ] Implementar endpoints de tienda
- [ ] Implementar endpoints de aceptar/rechazar metas
- [ ] Crear Command para notificaciones automáticas
- [ ] Registrar Command en Kernel.php
- [ ] Actualizar dashboard para incluir puntos
- [ ] Insertar productos de ejemplo
- [ ] Probar todos los endpoints

## 🎯 Flujo Completo de Renovación

1. Usuario ve notificación de membresía por vencer
2. Usuario toca la notificación → va a pantalla de planes
3. Usuario selecciona un plan y toca "Renovar"
4. App envía POST a `/api/v1/client/membership/renew`
5. Backend procesa el pago (integrar pasarela si es necesario)
6. Backend actualiza la membresía del cliente
7. Backend crea notificación de renovación exitosa
8. App muestra mensaje de éxito y actualiza datos del usuario
