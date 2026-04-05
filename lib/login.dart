// lib/login.dart  ← reemplaza tu archivo actual con este
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'forgot_password.dart';          // archivo nuevo (abajo)
import 'student_registration_screen.dart';
import 'services/api_service.dart';     // el servicio que creamos

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _usuarioCtrl   = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double>  _fadeAnimation;
  late Animation<Offset>  _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usuarioCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  // ─── LOGIN ────────────────────────────────────────────────────
  Future<void> _login() async {
    final username = _usuarioCtrl.text.trim();
    final password = _contrasenaCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService().login(username, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const azul  = Color(0xFF00205B);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/Universidad-Javeriana-Cali.jpg', fit: BoxFit.cover),
              Container(color: Colors.black.withOpacity(0.6)),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/logo-puj-cali-n.png', height: 100),
                          const SizedBox(height: 20),
                          const Text(
                            "Pontificia Universidad Javeriana de Cali",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azul),
                          ),
                          const SizedBox(height: 20),
                          const Text("Ingresa tus credenciales"),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usuarioCtrl,
                            decoration: const InputDecoration(labelText: "Usuario", border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _contrasenaCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azul,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: _loading
                                    ? const SizedBox(height: 20, width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("Entrar"),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // ─── Olvidé mi contraseña ─────────────────
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                            },
                            child: const Text("¿Olvidaste tu contraseña?",
                                style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const StudentRegistrationScreen()));
                            },
                            child: const Text("¿Eres nuevo? Regístrate aquí",
                                style: TextStyle(color: azul, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
