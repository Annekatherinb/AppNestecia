import 'package:flutter/material.dart';
import 'login.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombre = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController documento = TextEditingController();
  final TextEditingController codigo = TextEditingController();
  final TextEditingController semestre = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController usuario = TextEditingController();
  final TextEditingController contrasena = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Estudiante"),
        backgroundColor: const Color(0xFF00205B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _input("Nombre completo", nombre),
              _input("Edad", edad, type: TextInputType.number),
              _input("Número de documento", documento),
              _input("Código de estudiante", codigo),
              _input("Semestre", semestre, type: TextInputType.number),
              _input("Número de teléfono", telefono, type: TextInputType.phone),
              _input("Correo electrónico", correo, type: TextInputType.emailAddress),
              _input("Usuario para iniciar sesión", usuario),
              _input("Contraseña", contrasena, obscure: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarEstudiante,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00205B),
                ),
                child: const Text("Registrar"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ← Regresa al login
                },
                child: const Text(
                  "¿Ya tienes cuenta? Volver al inicio de sesión",
                  style: TextStyle(
                    color: Color(0xFF00205B),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _registrarEstudiante() {
    if (_formKey.currentState!.validate()) {
      estudiantesRegistrados.add({
        "usuario": usuario.text.trim(),
        "contrasena": contrasena.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Estudiante registrado exitosamente"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Regresa al login
    }
  }
}
