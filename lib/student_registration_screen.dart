import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard.dart';

// Simulación de usuarios registrados (como ya lo usas)
final List<Map<String, String>> estudiantesRegistrados = [];

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
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

  bool _hidePassword = true;

  @override
  void dispose() {
    nombre.dispose();
    edad.dispose();
    documento.dispose();
    codigo.dispose();
    semestre.dispose();
    telefono.dispose();
    correo.dispose();
    usuario.dispose();
    contrasena.dispose();
    super.dispose();
  }

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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              _input(
                "Nombre completo",
                nombre,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  final value = (v ?? "").trim();
                  if (value.isEmpty) return "Campo obligatorio";
                  if (value.length < 5) return "Ingresa nombre y apellido";
                  return null;
                },
              ),

              _input(
                "Edad",
                edad,
                type: TextInputType.number,
                maxLength: 2,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? "").trim());
                  if (n == null) return "Edad inválida";
                  if (n < 14 || n > 90) return "Edad fuera de rango";
                  return null;
                },
              ),

              _input(
                "Número de documento",
                documento,
                type: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final value = (v ?? "").trim();
                  if (value.length < 6) return "Documento inválido";
                  return null;
                },
              ),

              _input(
                "Código de estudiante",
                codigo,
                type: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final value = (v ?? "").trim();
                  if (value.length < 6) return "Código inválido";
                  return null;
                },
              ),

              _input(
                "Semestre",
                semestre,
                type: TextInputType.number,
                maxLength: 2,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? "").trim());
                  if (n == null || n < 1 || n > 16) return "Semestre inválido";
                  return null;
                },
              ),

              _input(
                "Teléfono (+57...)",
                telefono,
                type: TextInputType.phone,
                maxLength: 16,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9+]")),
                ],
                validator: (v) {
                  final ok = RegExp(r"^\+[1-9]\d{7,14}$")
                      .hasMatch((v ?? "").trim());
                  if (!ok) return "Formato inválido";
                  return null;
                },
              ),

              _input(
                "Correo electrónico",
                correo,
                type: TextInputType.emailAddress,
                validator: (v) {
                  final ok = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]{2,}$")
                      .hasMatch((v ?? "").trim());
                  if (!ok) return "Correo inválido";
                  return null;
                },
              ),

              _input(
                "Usuario",
                usuario,
                validator: (v) {
                  final value = (v ?? "").trim().toLowerCase();
                  final exists = estudiantesRegistrados.any(
                        (e) => e["usuario"] == value,
                  );
                  if (value.length < 4) return "Mínimo 4 caracteres";
                  if (exists) return "Usuario ya existe";
                  return null;
                },
              ),

              _passwordInput(),

              const SizedBox(height: 20),

              /// BOTÓN REGISTRAR
              ElevatedButton(
                onPressed: _registrarEstudiante,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00205B),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("Registrar"),
              ),

              const SizedBox(height: 10),

              /// BOTÓN SALTAR REGISTRO
              OutlinedButton(
                onPressed: _irSinRegistrar,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFF00205B)),
                ),
                child: const Text(
                  "Saltar e ir al dashboard",
                  style: TextStyle(
                    color: Color(0xFF00205B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
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

  Widget _passwordInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: contrasena,
        obscureText: _hidePassword,
        validator: (v) {
          final value = (v ?? "").trim();
          if (value.length < 7) return "Mínimo 7 caracteres";
          if (!RegExp(r"[A-Z]").hasMatch(value)) return "1 mayúscula requerida";
          if (!RegExp(r"[a-z]").hasMatch(value)) return "1 minúscula requerida";
          if (!RegExp(r"\d").hasMatch(value)) return "1 número requerido";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Contraseña",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _hidePassword = !_hidePassword),
            icon:
            Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
    );
  }

  Widget _input(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
        TextCapitalization textCapitalization = TextCapitalization.none,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: "",
        ),
      ),
    );
  }

  void _registrarEstudiante() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    estudiantesRegistrados.add({
      "usuario": usuario.text.trim().toLowerCase(),
      "contrasena": contrasena.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Estudiante registrado exitosamente"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  void _irSinRegistrar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }
}
