import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'student_registration_screen.dart';

List<Map<String, String>> estudiantesRegistrados = [
  {
    "usuario": "juan123",
    "contrasena": "123456",
  },
  {
    "usuario": "maria456",
    "contrasena": "abcdef",
  },
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF00205B);
    const dorado = Color(0xFFF6BE00);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/Universidad-Javeriana-Cali.jpg',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withOpacity(0.6)),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/logo-puj-cali-n.png', height: 100),
                            const SizedBox(height: 20),
                            const Text(
                              "Pontificia Universidad Javeriana de Cali",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: azul,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text("Ingresa tus credenciales"),
                            const SizedBox(height: 20),
                            TextField(
                              controller: usuarioController,
                              decoration: const InputDecoration(
                                labelText: "Usuario",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: contrasenaController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Contraseña",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _verificarCredenciales,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: azul,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text("Entrar"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const StudentRegistrationScreen()),
                                );
                              },
                              child: const Text(
                                "¿Eres nuevo? Regístrate aquí",
                                style: TextStyle(
                                  color: azul,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _verificarCredenciales() {
    final usuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text.trim();

    final existe = estudiantesRegistrados.any((est) =>
    est['usuario'] == usuario && est['contrasena'] == contrasena);

    if (existe) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario no registrado. Regístrate antes de continuar."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
