import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  String? tipoProcedimiento;
  double? peso;
  double? talla;
  double? imc;

  final TextEditingController pesoController = TextEditingController();
  final TextEditingController tallaController = TextEditingController();
  final TextEditingController imcController = TextEditingController();

  final List<String> tiposProcedimientos = [
    'Intubación orotraqueal',
    'Intubación nasotraqueal',
    'Máscara laríngea',
    'Anestesia subaracnoidea',
  ];

  @override
  void initState() {
    super.initState();
    pesoController.addListener(_updateIMC);
    tallaController.addListener(_updateIMC);
  }

  void _updateIMC() {
    final pesoVal = double.tryParse(pesoController.text);
    final tallaVal = double.tryParse(tallaController.text);
    if (pesoVal != null && tallaVal != null && tallaVal > 0) {
      final imcVal = pesoVal / ((tallaVal / 100) * (tallaVal / 100));
      setState(() {
        imc = imcVal;
        imcController.text = imcVal.toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    pesoController.dispose();
    tallaController.dispose();
    imcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF514073),
        title: const Text("Registro de Procedimientos"),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            icon: Icons.person,
            title: "Información del Paciente",
            child: _buildPacienteForm(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.medical_services,
            title: "Características de la Cirugía",
            child: _buildCirugiaForm(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.local_hospital,
            title: "Procedimiento Anestésico",
            child: Column(
              children: [
                _buildTipoProcedimientoDropdown(),
                const SizedBox(height: 10),
                if (tipoProcedimiento != null)
                  _buildProcedimientoForm(tipoProcedimiento!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF514073)),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF514073)),
        ),
        children: [Padding(padding: const EdgeInsets.all(12), child: child)],
      ),
    );
  }

  Widget _buildPacienteForm() {
    return Column(
      children: [
        const _StyledTextField('Edad (años)'),
        const _StyledDropdownField('Género', ['Masculino', 'Femenino', 'Otro']),
        _StyledTextField.controller('Peso (kg)', controller: pesoController),
        _StyledTextField.controller('Talla (cm)', controller: tallaController),
        _StyledTextField.controller('IMC', controller: imcController, enabled: false),
        const _StyledDropdownField('Apertura oral', ['<4 cm', '>4 cm']),
        const _StyledDropdownField('Distancia tiromentoniana', ['>6 cm', '<6 cm']),
        const _StyledDropdownField('Mallampati', ['I', 'II', 'III', 'IV']),
        const _StyledDropdownField('Dentadura', ['Completa', 'Parcial', 'Prótesis fija', 'Prótesis removible']),
        const _StyledTextField('Antecedentes relevantes'),
        const _StyledDropdownField('Clasificación ASA', ['I', 'II', 'III', 'IV']),
      ],
    );
  }

  Widget _buildCirugiaForm() {
    return Column(
      children: const [
        _StyledTextField('Tipo de cirugía'),
        _StyledDropdownField('Celeridad del procedimiento', ['Programada', 'Urgencia', 'Emergencia']),
        _StyledDropdownField('Ayuno', ['Completo', 'Incompleto']),
      ],
    );
  }

  Widget _buildTipoProcedimientoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Tipo de procedimiento',
      ),
      items: tiposProcedimientos.map((tipo) {
        return DropdownMenuItem<String>(value: tipo, child: Text(tipo));
      }).toList(),
      value: tipoProcedimiento,
      onChanged: (value) => setState(() => tipoProcedimiento = value),
    );
  }

  Widget _buildProcedimientoForm(String tipo) {
    final campos = {
      'Intubación orotraqueal': [
        'Cormack', 'Dispositivo de visualización', 'Tipo de inducción anestésica',
        'Tipo de tubo orotraqueal', 'Tamaño del tubo orotraqueal', 'Número de intentos'
      ],
      'Intubación nasotraqueal': [
        'Cormack', 'Dispositivo de visualización', 'Tipo de inducción anestésica',
        'Tamaño del tubo orotraqueal', 'Número de intentos', 'Éxito'
      ],
      'Máscara laríngea': [
        'Cormack', 'Tipo de dispositivo', 'Número de intentos', 'Éxito'
      ],
      'Anestesia subaracnoidea': [
        'Escoliosis', 'Grado de espalda', 'Uso de ecógrafo', 'Tipo de spinocath',
        'Grosor del spinocath', 'Nivel de punción', 'Tipo de abordaje',
        'Número de intentos', 'Cambio de tipo de abordaje', 'Éxito'
      ],
    };
    return Column(
      children: campos[tipo]!.map((campo) => _StyledTextField(campo)).toList(),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool enabled;

  const _StyledTextField(this.label, {this.controller, this.enabled = true});

  const _StyledTextField.controller(this.label, {this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _StyledDropdownField extends StatelessWidget {
  final String label;
  final List<String> options;

  const _StyledDropdownField(this.label, this.options);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
