# appnestesia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Guía: Levantar el ambiente de AppNestecia con Docker
 
## Arquitectura del proyecto
Tengamos en cuenta que tenemos:
 
- Base de Datos -> MySQL 8.0
- Api Rest -> Python con FastAPI
- FrontEnd -> Flutter with Dart (corre fuera de Docker, aparte)

## Paso 1 - Prerrequisitos
- Docker Desktop instalado y corriendo (Windows/Mac) o Docker Engine + Compose (Linux)
- Flutter SDK instalado (solo si vas a correr el frontend)
- Puertos libres: 8000 (API) y 3306 (MySQL)

## Paso 2 - Ubicarte en la carpeta raiz del proyecto

## Paso para la Ejecución de la app desde el ambiente Docker
- docker compose up --build

La primera vez tarda ~2 minutos porque descarga las imágenes.
Cuando veas esto, todo está funcionando:

```
anestesia_api  | INFO:     Application startup complete.
```

Para detenerlo: Ctrl+C
Para correrlo en segundo plano: `docker compose up -d`

Asegurarse que cada uno de los servicios esté corriendo correctamente
tengamos en cuenta que tenemos
 
 - Base de Datos -> Mysql 8.0
 - Api Rest -> Python con FASTapi
 - FrontEnd -> Flutter with dart

## Paso 4 - Verificar los servicios
- docker compose ps -> anestesia_db debe estar "healthy" y anestesia_api "Up"

- Abrir http://localhost:8000 -> debe responder {"status": "ok", "message": "API de Anestesiología funcionando"}

- Abri su navegador http://localhost:8000/docs
(Verá la documentación interactiva de Swagger donde puede
probar cada endpoint sin necesidad de Postman.)

- Ver logs si algo falla: docker compose logs -f

## Paso 5 - Levantar el Frontend Flutter
- flutter pub get
- flutter run -d chrome
- api_service.dart ya apunta a http://localhost:8000 en Web y a 10.0.2.2:8000 en emulador Android

### 5.1 Configurar la IP del backend

Abre `lib/services/api_service.dart` y busca:

```dart
const String _baseUrl = 'http://10.0.2.2:8000';
```

| Donde corres Flutter | IP a usar            |
|----------------------|----------------------|
| Emulador Android     | `10.0.2.2`           |
| Simulador iOS        | `localhost` o `127.0.0.1` |
| Dispositivo físico   | IP local de tu PC    |

Para saber tu IP local en Windows: `ipconfig` → IPv4 Address
Para saber tu IP local en Mac/Linux: `ifconfig` → inet

### 5.4 Permisos de red Android

En `android/app/src/main/AndroidManifest.xml` agrega dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Y en la etiqueta `<application>` agrega:

```xml
android:usesCleartextTraffic="true"
```

---

## PASO 6 — Flujo de autenticación

```
REGISTRO
App Flutter → POST /auth/register → Backend crea usuario en MySQL

LOGIN
App Flutter → POST /auth/login → Backend devuelve JWT token
               ApiService guarda el token en SharedPreferences

PETICIONES AUTENTICADAS
App Flutter → GET /auth/me  (con header: Authorization: Bearer <token>)
              GET /procedures
              POST /procedures
              etc.

OLVIDÉ CONTRASEÑA
App Flutter → POST /auth/forgot-password  (con email)
              Backend devuelve reset_token (en dev, en prod sería por email)
App Flutter → POST /auth/reset-password   (con token + nueva contraseña)

CAMBIAR CONTRASEÑA (autenticado)
App Flutter → POST /auth/change-password  (contraseña actual + nueva)
```

---

## ENDPOINTS DISPONIBLES

### Autenticación (`/auth`)
| Método | Ruta                    | Descripción                         |
|--------|-------------------------|-------------------------------------|
| POST   | /auth/register          | Crear cuenta nueva                  |
| POST   | /auth/login             | Iniciar sesión → devuelve JWT       |
| GET    | /auth/me                | Ver perfil del usuario autenticado  |
| PATCH  | /auth/me                | Actualizar nombre/correo/etc        |
| POST   | /auth/change-password   | Cambiar contraseña (autenticado)    |
| POST   | /auth/forgot-password   | Solicitar token de recuperación     |
| POST   | /auth/reset-password    | Restablecer con token               |

### Procedimientos (`/procedures`)
| Método | Ruta                       | Descripción                        |
|--------|----------------------------|------------------------------------|
| POST   | /procedures                | Guardar nuevo procedimiento        |
| GET    | /procedures                | Listar procedimientos del usuario  |
| GET    | /procedures/{id}           | Ver detalle de un procedimiento    |
| GET    | /procedures/cusum/data     | Datos CUSUM por tipo               |
| GET    | /procedures/metrics/me     | Métricas del dashboard             |


## Paso 6 - Apagar el ambiente

- docker compose down -> detiene los contenedores, conserva los datos de MySQL
- docker compose down -v -> además borra los datos (empezar desde cero)

## Notas
- Credenciales de la BD (ya definidas en docker-compose.yml, no requieren .env):
  - MYSQL_ROOT_PASSWORD: rootpassword
  - MYSQL_DATABASE: anestesia_db
  - MYSQL_USER: anestesia_user
  - MYSQL_PASSWORD: anestesia_pass
- Si Docker Desktop no está corriendo, "docker compose up" falla con error de conexión al daemon (npipe). Abrir Docker Desktop y esperar a que quede activo antes de correr el comando.
- Ejecutar siempre docker compose desde la raíz del proyecto, no desde la carpeta app.
- El warning "the attribute version is obsolete" es solo informativo, no rompe nada.