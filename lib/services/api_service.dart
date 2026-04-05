// lib/services/api_service.dart
//
// Servicio central para todas las llamadas HTTP al backend FastAPI.
// Usa el paquete http. Agrega en pubspec.yaml:
//   http: ^1.2.1
//   shared_preferences: ^2.2.3   (ya lo tienes)

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─── IP del backend según plataforma ──────────────────────────
// Cuando usas un emulador Android, `10.0.2.2` apunta a localhost.
// Para iOS o dispositivo físico, ajusta esta URL en la función _baseUrl.
String get _baseUrl {
  if (kIsWeb) return 'http://localhost:8000';   // Chrome / Flutter Web
  return 'http://10.0.2.2:8000';               // emulador Android por defecto
  // Para iOS cambia la línea de arriba a: return 'http://127.0.0.1:8000';
  // Para dispositivo físico:              return 'http://$_deviceIp:8000';
}

class ApiService {
  // ─── SINGLETON ──────────────────────────────────────────────
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ─── TOKEN ──────────────────────────────────────────────────
  String? _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  bool get isLoggedIn => _token != null;

  // ─── HEADERS ────────────────────────────────────────────────
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── HELPER: lanza excepción con el mensaje del servidor ────
  void _checkStatus(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw ApiException(body['detail'] ?? 'Error desconocido', res.statusCode);
    }
  }

  // ════════════════════════════════════════════════════════════
  //  AUTH
  // ════════════════════════════════════════════════════════════

  /// Registra un nuevo usuario. Devuelve el perfil creado.
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String nombre,
    required String apellido,
    String? codigo,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        if (codigo != null) 'codigo': codigo,
      }),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Login → guarda el token automáticamente.
  /// Envía form-data porque el backend usa OAuth2PasswordRequestForm.
  Future<void> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );
    _checkStatus(res);
    final data = jsonDecode(res.body);
    await saveToken(data['access_token']);
  }

  /// Perfil del usuario autenticado.
  Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(Uri.parse('$_baseUrl/auth/me'), headers: _headers);
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Actualiza nombre, apellido o correo.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/auth/me'),
      headers: _headers,
      body: jsonEncode(fields),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Cambiar contraseña (usuario autenticado).
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    _checkStatus(res);
  }

  /// Paso 1: solicitar token de recuperación.
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Paso 2: usar el token para establecer nueva contraseña.
  Future<void> resetPassword(String token, String newPassword) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({'token': token, 'new_password': newPassword}),
    );
    _checkStatus(res);
  }

  /// Logout local (borra el token).
  Future<void> logout() async => clearToken();

  // ════════════════════════════════════════════════════════════
  //  PROCEDIMIENTOS
  // ════════════════════════════════════════════════════════════

  /// Guarda un nuevo procedimiento con sus items.
  Future<Map<String, dynamic>> createProcedure({
    required String grupoPoblacional,
    required String tipoCirugia,
    required String grupoQuirurgico,
    required int intentos,
    required int exitos,
    String? comentarioEvaluador,
    String? firmaBase64,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/procedures'),
      headers: _headers,
      body: jsonEncode({
        'grupo_poblacional': grupoPoblacional,
        'tipo_cirugia': tipoCirugia,
        'grupo_quirurgico': grupoQuirurgico,
        'intentos': intentos,
        'exitos': exitos,
        if (comentarioEvaluador != null) 'comentario_evaluador': comentarioEvaluador,
        if (firmaBase64 != null) 'firma_base64': firmaBase64,
        'items': items,
      }),
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Lista de procedimientos del usuario autenticado.
  Future<List<dynamic>> getProcedures() async {
    final res = await http.get(Uri.parse('$_baseUrl/procedures'), headers: _headers);
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Datos CUSUM del usuario.
  Future<List<dynamic>> getCusum() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/procedures/cusum/data'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }

  /// Métricas del dashboard.
  Future<Map<String, dynamic>> getMetrics() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/procedures/metrics/me'),
      headers: _headers,
    );
    _checkStatus(res);
    return jsonDecode(res.body);
  }
}

// ─── Excepción personalizada ────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

// ─── Helper global para mostrar errores en pantalla ────────────
void showApiError(BuildContext context, Object error) {
  final msg = error is ApiException ? error.message : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
  );
}