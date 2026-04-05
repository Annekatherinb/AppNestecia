// lib/forgot_password.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  bool _loading = false;
  bool _tokenSent = false; // cambia la UI al paso 2

  // ─── PASO 1: pedir token ──────────────────────────────────────
  Future<void> _requestToken() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService().forgotPassword(_emailCtrl.text.trim());
      // En desarrollo el backend devuelve el token directamente
      // para que lo puedas copiar y pegar en el campo.
      final devToken = res['reset_token'];
      setState(() => _tokenSent = true);
      if (devToken != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: SelectableText("🔑 Token (solo dev): $devToken"),
          ),
        );
      }
    } catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── PASO 2: resetear contraseña ──────────────────────────────
  Future<void> _resetPassword() async {
    if (_tokenCtrl.text.trim().isEmpty || _newPassCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService().resetPassword(
        _tokenCtrl.text.trim(),
        _newPassCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Contraseña restablecida. Inicia sesión.")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF00205B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_tokenSent) ...[
              const Text("Ingresa tu correo registrado y te enviaremos un token de recuperación.",
                  style: TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _requestToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Solicitar token"),
              ),
            ] else ...[
              const Text("Ingresa el token recibido y tu nueva contraseña.",
                  style: TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: "Token de recuperación",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Nueva contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Restablecer contraseña"),
              ),
              TextButton(
                onPressed: () => setState(() => _tokenSent = false),
                child: const Text("← Volver"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
