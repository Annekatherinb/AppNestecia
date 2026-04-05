import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombre    = TextEditingController();
  final TextEditingController apellido  = TextEditingController();
  final TextEditingController codigo    = TextEditingController();
  final TextEditingController semestre  = TextEditingController();
  final TextEditingController correo    = TextEditingController();
  final TextEditingController usuario   = TextEditingController();
  final TextEditingController contrasena = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    nombre.dispose();
    apellido.dispose();
    codigo.dispose();
    semestre.dispose();
    correo.dispose();
    usuario.dispose();
    contrasena.dispose();
    super.dispose();
  }

  // ─── REGISTRO EN BACKEND ────────────────────────────────────
  Future<void> _registrarEstudiante() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ApiService().register(
        username: usuario.text.trim().toLowerCase(),
        password: contrasena.text.trim(),
        email:    correo.text.trim(),
        nombre:   nombre.text.trim(),
        apellido: apellido.text.trim(),
        codigo:   codigo.text.trim().isEmpty ? null : codigo.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Cuenta creada. Ya puedes iniciar sesión."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // vuelve al login
    } catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF00205B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Estudiante",
            style: TextStyle(color: Colors.white)),
        backgroundColor: azul,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              // ── Nombre ──────────────────────────────────────
              _input(
                "Nombre",
                nombre,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return "Campo obligatorio";
                  return null;
                },
              ),

              // ── Apellido ─────────────────────────────────────
              _input(
                "Apellido",
                apellido,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return "Campo obligatorio";
                  return null;
                },
              ),

              // ── Código ───────────────────────────────────────
              _input(
                "Código de estudiante (opcional)",
                codigo,
                type: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              // ── Semestre ─────────────────────────────────────
              _input(
                "Semestre",
                semestre,
                type: TextInputType.number,
                maxLength: 2,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return null; // opcional
                  final n = int.tryParse(v!.trim());
                  if (n == null || n < 1 || n > 16) return "Semestre inválido";
                  return null;
                },
              ),

              // ── Correo ───────────────────────────────────────
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

              // ── Usuario ──────────────────────────────────────
              _input(
                "Usuario",
                usuario,
                validator: (v) {
                  if ((v ?? "").trim().length < 4) return "Mínimo 4 caracteres";
                  return null;
                },
              ),

              // ── Contraseña ───────────────────────────────────
              _passwordInput(),

              const SizedBox(height: 20),

              // ── Botón registrar ──────────────────────────────
              ElevatedButton(
                onPressed: _loading ? null : _registrarEstudiante,
                style: ElevatedButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Registrar"),
              ),

              const SizedBox(height: 10),

              // ── Volver al login ──────────────────────────────
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "¿Ya tienes cuenta? Volver al inicio de sesión",
                  style: TextStyle(
                    color: azul,
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

  // ─── WIDGETS HELPERS ────────────────────────────────────────

  Widget _passwordInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: contrasena,
        obscureText: _hidePassword,
        validator: (v) {
          if ((v ?? "").trim().length < 6) return "Mínimo 6 caracteres";
          return null;
        },
        decoration: InputDecoration(
          labelText: "Contraseña",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _hidePassword = !_hidePassword),
            icon: Icon(
                _hidePassword ? Icons.visibility : Icons.visibility_off),
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
}