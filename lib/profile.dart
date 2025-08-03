import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nombre = "Juan";
  String apellido = "Pérez Gómez";
  String codigo = "202312345";
  String correo = "juan.perez@javeriana.edu.co";
  String especializacion = "Anestesiología";
  String semestre = "3";
  String fechaIngreso = "Agosto 2023";

  Map<String, int> procedimientos = {
    "Intubaciones": 25,
    "Anestesias Generales": 18,
    "Bloqueos Regionales": 12,
    "Anestesias Locales": 5,
  };

  bool editando = false;
  double _editBtnScale = 1.0;
  bool _desvaneciendo = false;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = nombre;
    _apellidoCtrl.text = apellido;
    _correoCtrl.text = correo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC), // Gris claro
      appBar: AppBar(
        backgroundColor:  Color(0XFFFAF3DD), // Color crema
        foregroundColor: Colors.black87,
        elevation: 2,
        title: Text("Perfil del Usuario", style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        actions: [
          GestureDetector(
            onTapDown: (_) => setState(() => _editBtnScale = 0.9),
            onTapUp: (_) {
              setState(() => _editBtnScale = 1.0);
              setState(() {
                if (editando) {
                  nombre = _nombreCtrl.text;
                  apellido = _apellidoCtrl.text;
                  correo = _correoCtrl.text;
                }
                editando = !editando;
              });
            },
            onTapCancel: () => setState(() => _editBtnScale = 1.0),
            child: AnimatedScale(
              scale: _editBtnScale,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CircleAvatar(
                  backgroundColor: editando ? Colors.green[400] : Colors.blueGrey,
                  child: Icon(
                    editando ? Icons.save : Icons.edit,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final confirmado = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("¿Cerrar sesión?"),
                  content: const Text("¿Estás seguro de que deseas salir?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Sí, salir", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmado == true) {
                setState(() => _desvaneciendo = true);
                await Future.delayed(const Duration(milliseconds: 700));
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            icon: const Icon(Icons.logout),
            color: Colors.red,
          ),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _desvaneciendo ? 0 : 1,
        duration: const Duration(milliseconds: 600),
        child: IgnorePointer(
          ignoring: _desvaneciendo,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/JAVE.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                _buildTextField("Nombre", _nombreCtrl),
                _buildTextField("Apellido", _apellidoCtrl),
                _buildInfo("Código de Estudiante", codigo),
                _buildTextField("Correo Electrónico", _correoCtrl),
                _buildInfo("Especialización", "$especializacion - Semestre $semestre"),
                _buildInfo("Fecha de Ingreso", fechaIngreso),
                const SizedBox(height: 24),
                const Divider(thickness: 1.2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Procedimientos Realizados:",
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var entry in procedimientos.entries)
                  _buildInfo(entry.key, "${entry.value}"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rubik(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextField(String title, TextEditingController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rubik(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          editando
              ? TextField(
            controller: controller,
            style: GoogleFonts.rubik(color: Colors.black87),
            cursorColor: Colors.cyan,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          )
              : Text(
            controller.text,
            style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
