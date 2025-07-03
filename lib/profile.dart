import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Perfil del Usuario"),
        foregroundColor: Colors.white,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: editando ? Colors.green : Colors.blueGrey,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (editando ? Colors.green : Colors.blueGrey).withOpacity(0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  editando ? Icons.save : Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final confirmado = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text("¿Cerrar sesión?", style: TextStyle(color: Colors.white)),
                  content: const Text("¿Estás seguro de que deseas salir?", style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Sí, salir", style: TextStyle(color: Colors.redAccent)),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.logout, color: Colors.white),
            ),
          )
        ],
      ),
      body: AnimatedOpacity(
        opacity: _desvaneciendo ? 0 : 1,
        duration: const Duration(milliseconds: 600),
        child: IgnorePointer(
          ignoring: _desvaneciendo,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/javeriana.png',
                  height: 80,
                ),
                const SizedBox(height: 20),
                _buildTextField("Nombre", _nombreCtrl),
                _buildTextField("Apellido", _apellidoCtrl),
                _buildInfo("Código de Estudiante", codigo),
                _buildTextField("Correo Electrónico", _correoCtrl),
                _buildInfo("Especialización", "$especializacion - Semestre $semestre"),
                _buildInfo("Fecha de Ingreso", fechaIngreso),
                const SizedBox(height: 24),
                const Divider(color: Colors.white70),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Procedimientos Realizados:",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTextField(String title, TextEditingController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          editando
              ? TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.cyan,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          )
              : Text(controller.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
