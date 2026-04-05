// lib/Register.dart  ← reemplaza tu archivo actual
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import 'dart:convert';

import 'services/api_service.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> with TickerProviderStateMixin {

  final Color primaryColor = const Color(0xFF5ED3C6);

  String? grupoPoblacional;
  String? grupoQuirurgico;
  String? tipoCirugia;

  List<String> gruposQuirurgicos = [
    "Cirugía general", "Cirugía pediátrica", "Obstetricia",
    "Ortopedia", "Ginecología", "Oftalmología", "Urología",
    "Neurocirugía", "ORL", "Cirugía plástica",
    "Cirugía cardiovascular", "Cirugía de tórax", "Cirugía maxilofacial"
  ];

  Map<String, bool?> procedimientos = {
    "Máscara laríngea": null,
    "Intubación orotraqueal": null,
    "Intubación nasotraqueal": null,
    "Anestesia subaracnoidea": null,
    "Catéter epidural": null,
    "Línea arterial": null,
    "Catéter venoso central": null,
    "Bloqueo regional": null,
  };

  int intentos = 1;
  int exitos   = 1;
  bool _saving = false;

  final comentarioController = TextEditingController();

  final SignatureController firmaController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  // ─── GUARDAR EN BACKEND ──────────────────────────────────────
  Future<void> _guardar() async {
    // Validaciones básicas
    if (grupoPoblacional == null || tipoCirugia == null || grupoQuirurgico == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos requeridos")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Convertir firma a base64 si existe
      String? firmaB64;
      if (firmaController.isNotEmpty) {
        final bytes = await firmaController.toPngBytes();
        if (bytes != null) firmaB64 = base64Encode(bytes);
      }

      // Convertir checklist a lista
      final items = procedimientos.entries
          .where((e) => e.value != null)
          .map((e) => {'nombre': e.key, 'realizado': e.value})
          .toList();

      await ApiService().createProcedure(
        grupoPoblacional:    grupoPoblacional!,
        tipoCirugia:         tipoCirugia!,
        grupoQuirurgico:     grupoQuirurgico!,
        intentos:            intentos,
        exitos:              exitos,
        comentarioEvaluador: comentarioController.text.trim().isEmpty
            ? null
            : comentarioController.text.trim(),
        firmaBase64:         firmaB64,
        items:               items,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registro guardado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      if (mounted) showApiError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          "Registro de Procedimiento",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Grupo Poblacional"),
            _grupoPoblacional(),
            const SizedBox(height: 20),
            _sectionTitle("Características de la Cirugía"),
            _tipoCirugia(),
            const SizedBox(height: 20),
            _sectionTitle("Grupo Quirúrgico de la Intervención"),
            _grupoQuirurgicoBuscable(),
            const SizedBox(height: 25),
            _sectionTitle("Procedimiento"),
            _procedimientosWidget(),
            const SizedBox(height: 25),
            _sectionTitle("Resultados"),
            _metricas(),
            const SizedBox(height: 30),
            _evaluacionDocente(),
            const SizedBox(height: 30),
            _guardarButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
  );

  Widget _grupoPoblacional() => Row(
    children: ["Adulto", "Pediátrico"].map((e) {
      final selected = grupoPoblacional == e;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: selected ? primaryColor : Colors.white,
              foregroundColor: selected ? Colors.white : Colors.black,
            ),
            onPressed: () => setState(() => grupoPoblacional = e),
            child: Text(e),
          ),
        ),
      );
    }).toList(),
  );

  Widget _tipoCirugia() => Wrap(
    spacing: 10,
    children: ["Emergencia", "Urgencia", "Programada"].map((e) => ChoiceChip(
      label: Text(e),
      selected: tipoCirugia == e,
      selectedColor: primaryColor,
      onSelected: (_) => setState(() => tipoCirugia = e),
    )).toList(),
  );

  Widget _grupoQuirurgicoBuscable() => TextFormField(
    readOnly: true,
    decoration: const InputDecoration(
      hintText: "Seleccionar grupo quirúrgico",
      border: OutlineInputBorder(),
    ),
    controller: TextEditingController(text: grupoQuirurgico ?? ""),
    onTap: () async {
      final selected = await showSearch(
        context: context,
        delegate: GrupoSearchDelegate(gruposQuirurgicos),
      );
      if (selected != null && selected.isNotEmpty) {
        setState(() => grupoQuirurgico = selected);
      }
    },
  );

  Widget _procedimientosWidget() => Column(
    children: procedimientos.keys.map((proc) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.1))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(proc)),
            Row(children: [_siNoButton(proc, true), const SizedBox(width: 6), _siNoButton(proc, false)]),
          ],
        ),
      );
    }).toList(),
  );

  Widget _siNoButton(String proc, bool valor) {
    final selected = procedimientos[proc] == valor;
    return GestureDetector(
      onTap: () => setState(() => procedimientos[proc] = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? (valor ? Colors.green : Colors.red) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(valor ? "Sí" : "No",
            style: TextStyle(color: selected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _metricas() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _stepper("Intentos", intentos, (v) => setState(() => intentos = v)),
      _stepper("Éxitos",   exitos,   (v) => setState(() => exitos   = v)),
    ],
  );

  Widget _stepper(String label, int value, Function(int) onChanged) => Column(
    children: [
      Text(label),
      Row(children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Text(value.toString()),
        IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1)),
      ]),
    ],
  );

  Widget _evaluacionDocente() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Evaluación Docente", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextField(
          controller: comentarioController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Comentario del evaluador",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        const Text("Firma digital"),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(controller: firmaController, backgroundColor: Colors.white),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => firmaController.clear(),
            child: const Text("Limpiar firma"),
          ),
        ),
      ],
    ),
  );

  Widget _guardarButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _saving ? null : _guardar,
      child: _saving
          ? const SizedBox(height: 22, width: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Guardar Registro", style: TextStyle(fontSize: 16)),
    ),
  );
}

// ─── Search delegate (igual que antes) ───────────────────────────
class GrupoSearchDelegate extends SearchDelegate<String> {
  final List<String> grupos;
  GrupoSearchDelegate(this.grupos);

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = "")];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ""));

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final results = grupos.where((g) => g.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      children: results.map((g) => ListTile(title: Text(g), onTap: () => close(context, g))).toList(),
    );
  }
}
