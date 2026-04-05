// lib/history.dart  ← reemplaza tu archivo actual
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Register.dart';
import 'services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color primaryColor = const Color(0xFF1E3A5F);

  bool _loading = true;
  bool sortDescending = true;
  String? selectedGrupo;
  String? expandedId;

  List<Map<String, dynamic>> _procedures = [];

  final List<String> gruposIntervencion = [
    "Cirugía general", "Cirugía pediátrica", "Obstetricia",
    "Ortopedia", "Ginecología", "Oftalmología", "Urología",
    "Neurocirugía", "ORL", "Cirugía plástica",
    "Cirugía cardiovascular", "Cirugía de tórax", "Cirugía maxilofacial",
    "Anestesia cardiovascular", "Cirugía vascular",
  ];

  @override
  void initState() {
    super.initState();
    _loadProcedures();
  }

  Future<void> _loadProcedures() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getProcedures();
      setState(() {
        _procedures = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        showApiError(context, e);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _procedures.where((p) {
      if (selectedGrupo == null) return true;
      return p['grupo_quirurgico'] == selectedGrupo;
    }).toList();

    filtered.sort((a, b) {
      final da = DateTime.parse(a['fecha']);
      final db = DateTime.parse(b['fecha']);
      return sortDescending ? db.compareTo(da) : da.compareTo(db);
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Histórico de Procedimientos",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(sortDescending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
            onPressed: () => setState(() => sortDescending = !sortDescending),
          ),
          // Botón refrescar
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProcedures,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filtro ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: Text(selectedGrupo ?? "Filtrar por grupo de intervención"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  onPressed: _openGrupoSelector,
                ),
                if (selectedGrupo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      label: Text(selectedGrupo!),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => setState(() => selectedGrupo = null),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Lista ────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text("No hay registros"))
                    : RefreshIndicator(
                        onRefresh: _loadProcedures,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _procedureCard(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo registro",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroPage()));
          _loadProcedures(); // recarga al volver
        },
      ),
    );
  }

  Widget _procedureCard(Map<String, dynamic> p) {
    final id = p['id'].toString();
    final isExpanded = expandedId == id;
    final fecha = DateTime.parse(p['fecha']);
    final tipo = p['tipo_cirugia'] ?? '';

    return GestureDetector(
      onTap: () => setState(() => expandedId = isExpanded ? null : id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(p['grupo_quirurgico'] ?? '',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17)),
                ),
                _badge(tipo),
              ],
            ),
            const SizedBox(height: 6),
            Text("${fecha.year}/${fecha.month.toString().padLeft(2,'0')}/${fecha.day.toString().padLeft(2,'0')} "
                "${fecha.hour}:${fecha.minute.toString().padLeft(2,'0')}",
                style: const TextStyle(color: Colors.grey)),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  _detailRow("ID del procedimiento", id),
                  _detailRow("Grupo poblacional", p['grupo_poblacional'] ?? ''),
                  _detailRow("Tipo de cirugía", tipo),
                  _detailRow("Intentos", p['intentos'].toString()),
                  _detailRow("Éxitos", p['exitos'].toString()),
                  if (p['comentario_evaluador'] != null)
                    _detailRow("Comentario", p['comentario_evaluador']),
                  const SizedBox(height: 6),
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );

  Widget _badge(String tipo) {
    Color color;
    if (tipo == "Emergencia") {
      color = Colors.red;
    } else if (tipo == "Urgencia") color = Colors.orange;
    else color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(tipo, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _openGrupoSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final searchCtrl = TextEditingController();
        List<String> filtered = List.from(gruposIntervencion);

        return StatefulBuilder(builder: (context, setModal) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(height: 4, width: 40,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Seleccionar Grupo", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (v) => setModal(() {
                    filtered = gruposIntervencion.where((g) => g.toLowerCase().contains(v.toLowerCase())).toList();
                  }),
                  decoration: const InputDecoration(
                    hintText: "Buscar grupo...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(filtered[i]),
                    onTap: () {
                      setState(() => selectedGrupo = filtered[i]);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
