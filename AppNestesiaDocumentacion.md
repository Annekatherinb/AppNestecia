# Documentación Técnica — AppNestesia

Documentación reorganizada por capas de arquitectura: **Base de Datos**, **API REST**, **Autenticación** y **Frontend (Flutter)**.

---

## Índice

1. [Base de Datos](#1-base-de-datos)
2. [API REST — `api_service.dart`](#2-api-rest--api_servicedart)
3. [Autenticación](#3-autenticación)
4. [Frontend (Flutter)](#4-frontend-flutter)
5. [Diagrama general de flujo](#5-diagrama-general-de-flujo)

---

## 1. Base de Datos

Ninguno de los archivos analizados hasta el momento implementa directamente el acceso a base de datos: toda la persistencia ocurre del lado del backend, al cual el frontend accede exclusivamente a través de `ApiService` (capa HTTP).

## 1.1 Modelo Entidad-Relación (MER)

**USERS**

| Campo | Tipo | Llave |
|---|---|---|
| id | INT UNSIGNED | PK |
| username | VARCHAR(60) | |
| email | VARCHAR(120) | |
| password_hash | VARCHAR(255) | |
| nombre | VARCHAR(80) | |
| apellido | VARCHAR(80) | |
| codigo | VARCHAR(20) | |
| especializacion | VARCHAR(100) | |
| semestre | TINYINT | |
| fecha_ingreso | DATE | |
| rol | ENUM | |
| is_active | BOOLEAN | |

**PROCEDURES**

| Campo | Tipo | Llave |
|---|---|---|
| id | INT UNSIGNED | PK |
| user_id | INT UNSIGNED | FK → USERS.id |
| grupo_poblacional | ENUM | |
| tipo_cirugia | ENUM | |
| grupo_quirurgico | VARCHAR(100) | |
| intentos | TINYINT | |
| exitos | TINYINT | |
| comentario_evaluador | TEXT | |
| firma_base64 | LONGTEXT | |
| fecha | DATETIME | |
| created_at | DATETIME | |
| updated_at | DATETIME | |

**PROCEDURE_ITEMS**

| Campo | Tipo | Llave |
|---|---|---|
| id | INT UNSIGNED | PK |
| procedure_id | INT UNSIGNED | FK → PROCEDURES.id |
| nombre | VARCHAR(100) | |
| realizado | BOOLEAN | |

**CUSUM_RECORDS**

| Campo | Tipo | Llave |
|---|---|---|
| id | INT UNSIGNED | PK |
| user_id | INT UNSIGNED | FK → USERS.id |
| procedure_id | INT UNSIGNED | FK → PROCEDURES.id |
| cusum_value | DECIMAL(10,4) | |
| alerta | BOOLEAN | |
| umbral | DECIMAL(10,4) | |
| fecha | DATETIME | |

**USER_METRICS**

| Campo | Tipo | Llave |
|---|---|---|
| id | INT UNSIGNED | PK |
| user_id | INT UNSIGNED | FK → USERS.id (UNIQUE) |
| total_procedimientos | INT | |
| tasa_exito | DECIMAL(5,2) | |
| intubaciones | INT | |
| anestesias_generales | INT | |
| bloqueos_regionales | INT | |
| anestesias_locales | INT | |
| updated_at | DATETIME | |

### 1.2 Relaciones

| Relación | Cardinalidad | Descripción |
|---|---|---|
| USERS → PROCEDURES | 1:N | Un usuario registra muchos procedimientos |
| PROCEDURES → PROCEDURE_ITEMS | 1:N | Un procedimiento tiene muchos ítems de checklist |
| PROCEDURES → CUSUM_RECORDS | 1:N | Un procedimiento genera muchos registros CUSUM |
| USERS → USER_METRICS | 1:1 | Un usuario tiene un único resumen de métricas |
| USERS → CUSUM_RECORDS | 1:N (relación indirecta, vía `user_id` en CUSUM_RECORDS) | Permite consultar CUSUM por usuario sin pasar por PROCEDURES |

### 1.3 Relación con el frontend / API

| Tabla | Alimentada/consultada por | Pantalla(s) |
|---|---|---|
| USERS | `POST /auth/register`, `POST /auth/login`, `GET /auth/me`, `PATCH /auth/me` | `student_registration_screen.dart`, `login.dart`, `profile.dart` |
| PROCEDURES | `POST /procedures`, `GET /procedures` | `Register.dart`, `history.dart` |
| PROCEDURE_ITEMS | `POST /procedures` (dentro del payload `items`) | `Register.dart` |
| CUSUM_RECORDS | `GET /procedures/cusum/data` | `cusum.dart` |
| USER_METRICS | `GET /procedures/metrics/me` | `dashboard.dart` ( endpoint existe pero no está conectado) |

### Observaciones importantes

- **`dashboard.dart`**: la sección de resultados (`_buildResultsSection()`) usa datos definidos directamente en el código (`_ResultItem`), **no** consulta `ApiService.getMetrics()`. El endpoint existe en el backend/servicio, pero aún no está conectado en esta pantalla.
- **`profile.dart`**: los datos del perfil y el resumen de procedimientos están definidos en el estado local del widget. Esta pantalla **no** hace llamadas a `ApiService` ni persiste cambios en el backend.
- **`settings_page.dart`**: las preferencias (notificaciones, haptics, modo oscuro) se manejan con `setState` local, sin persistencia ni conexión a backend/BD.
- El cálculo matemático de la curva CUSUM **no** ocurre en el frontend; `cusum.dart` solo consume y grafica los valores ya calculados por el backend.

> El esquema real de la base de datos (tablas, relaciones) no está documentado en estos archivos — corresponde documentarlo al revisar el código del backend.

---

## 2. API REST — `api_service.dart`

Archivo central de comunicación entre Flutter y el backend. Ubicado en `lib/services/api_service.dart`.

### Responsabilidades

- Autenticación y gestión de usuarios
- Recuperación y cambio de contraseñas
- Gestión de procedimientos anestésicos
- Consulta de procedimientos registrados
- Obtención de datos para las curvas CUSUM
- Obtención de métricas del dashboard
- Manejo centralizado de errores de la API

### Configuración de la URL base (`_baseUrl`)

| Plataforma | URL |
|---|---|
| Flutter Web | `http://localhost:8000` |
| Emulador Android | `http://10.0.2.2:8000` |
| iOS / dispositivo físico | *(pendiente de configurar)* |

### Patrón Singleton

```dart
static final ApiService _instance = ApiService._internal();
factory ApiService() => _instance;
```

Todas las pantallas comparten una única instancia, que conserva el token en memoria.

### Encabezados HTTP (`_headers`)

- `Content-Type: application/json` (siempre)
- `Authorization: Bearer <token>` (cuando existe token cargado)

### Manejo centralizado de errores

- `_checkStatus()`: si el código HTTP ≥ 400, extrae el campo `detail` del backend y lanza `ApiException` (contiene `message` y `statusCode`).
- `showApiError(context, error)`: función global que muestra el error al usuario mediante `SnackBar`, usando el mensaje de `ApiException` si aplica.

### Tabla de endpoints

| Método | Endpoint | Función | Sección |
|---|---|---|---|
| POST | `/auth/register` | Registrar usuario | Auth |
| POST | `/auth/login` | Autenticar usuario (form-urlencoded, OAuth2PasswordRequestForm) | Auth |
| GET | `/auth/me` | Obtener perfil | Auth |
| PATCH | `/auth/me` | Actualizar perfil | Auth |
| POST | `/auth/change-password` | Cambiar contraseña | Auth |
| POST | `/auth/forgot-password` | Solicitar recuperación | Auth |
| POST | `/auth/reset-password` | Restablecer contraseña | Auth |
| POST | `/procedures` | Crear procedimiento | Procedimientos |
| GET | `/procedures` | Obtener procedimientos | Procedimientos |
| GET | `/procedures/cusum/data` | Obtener datos CUSUM | Procedimientos |
| GET | `/procedures/metrics/me` | Obtener métricas del dashboard | Procedimientos |
| — | `logout()` | Cierre de sesión local (no llama al backend) | Auth |

### Métodos de procedimientos (detalle)

- **`createProcedure()`** → `POST /procedures`. Recibe `grupoPoblacional`, `tipoCirugia`, `grupoQuirurgico`, `intentos`, `exitos`, `comentarioEvaluador`, `firmaBase64`, `items`.
- **`getProcedures()`** → `GET /procedures`. Alimenta el histórico.
- **`getCusum()`** → `GET /procedures/cusum/data`. Alimenta el gráfico CUSUM.
- **`getMetrics()`** → `GET /procedures/metrics/me`. Existe en el servicio, pero **aún no está conectado** al dashboard.

### Dependencias

`dart:convert`, `flutter/foundation.dart` (detección de `kIsWeb`), `flutter/material.dart` (SnackBar), `http`, `shared_preferences` (persistencia del token).

---

## 3. Autenticación

### 3.1 Gestión del token (`ApiService`)

| Elemento | Descripción |
|---|---|
| `_token` | Variable en memoria con el token actual |
| Clave en `SharedPreferences` | `auth_token` |
| `loadToken()` | Carga el token guardado a memoria |
| `saveToken()` | Guarda el token en memoria y en `SharedPreferences` |
| `clearToken()` | Elimina el token de memoria y almacenamiento local |
| `isLoggedIn` | Indica si hay un token cargado actualmente |

**Flujo de login:**

```
LoginScreen → ApiService.login() → POST /auth/login → API REST
    → access_token → saveToken() → SharedPreferences
```

### 3.2 `login.dart` — Pantalla de inicio de sesión

- Captura usuario/contraseña con `_usuarioCtrl` y `_contrasenaCtrl` (`obscureText` para la contraseña).
- Valida campos no vacíos (`trim()`) antes de enviar — mensaje: *"Completa todos los campos"*.
- `_login()` llama a `ApiService().login(username, password)`.
- Estado `_loading` deshabilita el botón y muestra `CircularProgressIndicator` durante la solicitud.
- Errores capturados con try/catch → `showApiError(context, e)`.
- Éxito → `Navigator.pushReplacement` hacia `DashboardPage`.
- Accesos adicionales: *"¿Olvidaste tu contraseña?"* → `forgot_password.dart`; *"¿Eres nuevo? Regístrate aquí"* → `student_registration_screen.dart`.

```
                    ┌──→ Dashboard
Login ──────────────┼──→ Recuperación de contraseña
                    └──→ Registro de estudiante
```

### 3.3 `forgot_password.dart` — Recuperación de contraseña

Proceso en dos pasos, controlado por `_tokenSent`:

1. **Solicitud del token** — `_requestToken()` envía el correo (`_emailCtrl`) vía `ApiService().forgotPassword()` → `POST /auth/forgot-password`.
   - ⚠️ *Nota de seguridad*: en desarrollo, el backend puede devolver `reset_token` directamente, mostrado en un `SnackBar` ("Token (solo dev): ..."). El propio código indica que esto debe eliminarse en producción.
2. **Restablecimiento** — `_resetPassword()` envía `_tokenCtrl` + `_newPassCtrl` vía `ApiService().resetPassword()` → `POST /auth/reset-password`.

```
LoginScreen → ¿Olvidaste tu contraseña? → forgot_password.dart
  → Ingresar correo → POST /auth/forgot-password → Token
  → Ingresar token + nueva contraseña → POST /auth/reset-password
  → Contraseña actualizada → LoginScreen
```

Estado: `_loading` (evita solicitudes duplicadas), `_tokenSent` (controla el paso mostrado).

### 3.4 `student_registration_screen.dart` — Registro de nuevos estudiantes

**Campos del formulario:**

| Campo | Validación |
|---|---|
| Nombre | Obligatorio |
| Apellido | Obligatorio |
| Código de estudiante | Opcional, solo numérico |
| Semestre | Opcional |
| Correo electrónico | Obligatorio |
| Usuario | Obligatorio, mínimo 4 caracteres |
| Contraseña | Obligatoria, mínimo 6 caracteres |

- Validación centralizada con `GlobalKey<FormState>` y `AutovalidateMode.onUserInteraction`.
- `_registrarEstudiante()` → `ApiService().register(username, password, email, nombre, apellido, codigo)` → `POST /auth/register`.
- El **semestre** se captura en la UI pero **no se envía** actualmente en la llamada a `register()`.
- Contraseña con visibilidad alternable (`_hidePassword`).
- Éxito → mensaje *"Cuenta creada. Ya puedes iniciar sesión."* → `Navigator.pop()` de regreso al login.

### 3.5 Persistencia del onboarding

`main.dart` consulta `SharedPreferences` (clave `seenOnboarding`) para decidir si mostrar el onboarding (`carousel.dart`) antes del login. Este estado es independiente del token de autenticación.

---

## 4. Frontend (Flutter)

### 4.1 Flujo de arranque

```
main.dart → SplashScreenApp → CarouselScreen (onboarding) → LoginScreen → DashboardPage
```

#### `main.dart`
- Punto de entrada. Inicializa Flutter (`WidgetsFlutterBinding`), consulta `seenOnboarding` en `SharedPreferences`, ejecuta `runApp()`.
- **`MyApp`**: widget raíz; configura `MaterialApp` (tema, título, pantalla inicial, banner debug desactivado).
- **`SplashScreenApp`**: pantalla inicial; recibe `showOnboarding`.
- Dependencias: `flutter/material.dart`, `shared_preferences`.

#### `splash_screen.dart`
- Pantalla de bienvenida animada antes del onboarding.
- Fondo degradado animado (`TweenAnimationBuilder` + `LinearGradient`), logo con efecto holograma 3D (`_buildHologramLogo()`), fade-in general, nombre de la app con efecto de escritura (`AnimatedTextKit`).
- Animaciones: `AnimationController` (2s), `CurvedAnimation` (easeInOut), `FadeScaleTransition`.
- Navega a `CarouselScreen` mediante `AnimatedSplashScreen` (`page_transition`).
- Dependencias: `animated_splash_screen`, `page_transition`, `animated_text_kit`, `animations`, `google_fonts`.
- Logo: `assets/images/principalLOG.png`.

#### `carousel.dart` — Onboarding
- Tres páginas (`OnboardingItem`: `image`, `title`, `description`):
  1. *Organiza tus anestesias*
  2. *Acceso rápido*
  3. *Seguridad primero*
- Implementado con `CarouselSlider` (una página visible, sin loop infinito, `_onPageChanged`).
- Indicadores dinámicos (`_buildIndicators()`), botón "Iniciar sesión" animado (`FadeTransition` + `ScaleTransition`) al llegar a la última página.
- Opción "Saltar" disponible antes de la última página.
- `_goToLogin()`: guarda `seenOnboarding = true` en `SharedPreferences` y navega (`pushReplacement`) a `LoginScreen`.
- Imágenes: `assets/images/C1.png`, `C2.png`, `C3.png`.
- Dependencias: `carousel_slider`, `shared_preferences`.

### 4.2 `dashboard.dart` — Pantalla principal

- **`DashboardPage`**: administra navegación entre 3 secciones vía `_tabIndex` e `IndexedStack` — *Inicio*, *Chat*, *Config*.
- **`_HomeDashboard`**: encabezado de bienvenida, acceso a perfil, menú de funcionalidades, sección de resultados.
- **Menú de funcionalidades** (`_buildMenuGrid()`): tarjetas hacia `cusum.dart`, `history.dart`, `Register.dart`. Distribución adaptativa (2 columnas en pantallas pequeñas, 3 en grandes) vía `LayoutBuilder`.
- **Resultados** (`_buildResultsSection()`): indicadores circulares (`CircularPercentIndicator`) con modelo `_ResultItem` — *ver nota en sección de Base de Datos: valores fijos en código, no conectados a `getMetrics()`*.
- **Navegación inferior**: Inicio (`_HomeDashboard`) / Chat (`ChatBotPage`) / Config (`SettingsPage`), con botón flotante de acceso rápido al chat.
- Dependencias: `google_fonts`, `percent_indicator`, `profile.dart`, `history.dart`, `cusum.dart`, `Register.dart`, `ChatBotPage.dart`, `settings_page.dart`.

### 4.3 `Register.dart` — Registro de procedimientos

- Selección de **grupo poblacional** (Adulto/Pediátrico), **tipo de cirugía** (Emergencia/Urgencia/Programada), **grupo quirúrgico** (buscador con `GrupoSearchDelegate`, ~14 grupos disponibles: cirugía general, pediátrica, obstetricia, ortopedia, etc.).
- **Checklist de procedimientos** (`Map<String, bool?>`, estados: `null`/`true`/`false`) — 8 ítems: máscara laríngea, intubación orotraqueal/nasotraqueal, anestesia subaracnoidea, catéter epidural, línea arterial, catéter venoso central, bloqueo regional.
- **Resultados**: intentos y éxitos (steppers).
- **Evaluación docente**: comentario (`comentarioController`) + firma digital (paquete `signature`) → PNG → Base64.
- `_guardar()`: valida campos obligatorios, convierte firma y checklist, llama `ApiService().createProcedure(...)` → `POST /procedures`.
- Estado `_saving` deshabilita el botón y muestra progreso durante el envío.
- Dependencias: `google_fonts`, `signature`, `dart:convert`, `services/api_service.dart`.

### 4.4 `history.dart` — Histórico de procedimientos

- `_loadProcedures()` → `ApiService().getProcedures()` → `GET /procedures`.
- Filtro por `selectedGrupo` (grupo quirúrgico) y ordenamiento por `fecha` (`sortDescending`).
- Tarjetas expandibles (`_procedureCard()`): resumen (grupo, tipo de cirugía, fecha) → detalle (ID, grupo poblacional, intentos, éxitos, comentario) al expandir.
- Etiqueta visual por tipo de cirugía (`_badge()`): Emergencia = rojo, Urgencia = naranja, Programada = verde.
- Selector de grupo con búsqueda (`_openGrupoSelector()`, `ModalBottomSheet`).
- `RefreshIndicator` + botón de refresco manual.
- Botón flotante "Nuevo registro" → `Register.dart`; al volver, recarga la lista.
- Dependencias: `google_fonts`, `Register.dart`, `services/api_service.dart`.

### 4.5 `cusum.dart` — Análisis CUSUM

- `_loadCusum()` → `ApiService().getCusum()` → `GET /procedures/cusum/data`.
- Cuatro tipos de procedimiento: `orotraqueal`, `nasotraqueal`, `mascara_laringea`, `subaracnoidea`, organizados en `cusumDataByType`.
- Selector horizontal de procedimiento (`selectedProcedure`).
- Gráfico de líneas con `fl_chart` (`LineChart`, puntos `FlSpot`).
- Estados: cargando, sin datos ("Sin datos para este procedimiento"), con datos.
- Botón de refresco vuelve a ejecutar `_loadCusum()`.
- **No calcula** la curva CUSUM — solo consume y grafica valores ya calculados por el backend.
- Dependencias: `fl_chart`, `services/api_service.dart`.

### 4.6 `profile.dart` — Perfil del usuario

- Muestra: nombre, apellido, código de estudiante, correo, especialización, semestre, fecha de ingreso, resumen de procedimientos.
- Edición (`editando`) de nombre/apellido/correo mediante `TextField` (botón con `AnimatedScale`).
- Cierre de sesión con confirmación (`AlertDialog`) → animación de desvanecimiento → `Navigator.of(context).popUntil((route) => route.isFirst)`.
- **No conectado a `ApiService`**: los datos y la edición son actualmente solo estado local del widget (ver nota en sección de Base de Datos).
- Dependencias: `google_fonts`, `assets/images/JAVE.png`.

### 4.7 `settings_page.dart` — Configuración

Secciones:

```
Cuenta      → Perfil, Seguridad
Aplicación  → Notificaciones, Haptics, Modo oscuro, Idioma
Soporte     → Ayuda, Reportar un problema, Acerca de
Sesión      → Cerrar sesión
```

- Preferencias (`notif`, `haptics`, `darkMode`) manejadas con `setState`, **sin persistencia** ni aplicación global.
- Perfil, Seguridad, Idioma, Ayuda y Reportar un problema: acciones actualmente vacías.
- Cierre de sesión: modo demostrativo (mensaje en pantalla); el código tiene un `TODO` para conectarlo con `ApiService.logout()`.
- Dependencias: `google_fonts`.

---

## 5. Diagrama general de flujo

```
┌───────────────────────────────────────────────────────────┐
│                      FRONTEND (Flutter)                    │
│                                                            │
│  main.dart → splash_screen.dart → carousel.dart            │
│       ↓                                                    │
│  login.dart ──┬── forgot_password.dart                     │
│               └── student_registration_screen.dart          
│       ↓                                                    │
│  dashboard.dart                                            │
│   ├── Register.dart   (crear procedimiento)                │
│   ├── history.dart    (listar procedimientos)              │
│   ├── cusum.dart       (curva CUSUM)                       │
│   ├── profile.dart     (estado local, sin backend aún)     │
│   └── settings_page.dart (estado local, sin backend aún)   │
└──────────────────────┬────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                 API REST — ApiService (Singleton)         │
│  • Token JWT en memoria + SharedPreferences               │
│  • Headers: Content-Type, Authorization Bearer            │
│  • Manejo centralizado de errores (ApiException)          
└──────────────────────┬────────────────────────────────────┘
                        │  HTTP
                        ▼
┌───────────────────────────────────────────────────────────┐
│                    BACKEND (API REST)                     │
└──────────────────────┬────────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                     BASE DE DATOS                         │          │
└───────────────────────────────────────────────────────────┘
```
