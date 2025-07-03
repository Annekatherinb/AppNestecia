import 'package:flutter/material.dart';

class Procedure {
  final String id;
  final DateTime date;
  final Duration duration;

  Procedure({required this.id, required this.date, required this.duration});
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  List<Procedure> procedures = [
    Procedure(id: "PCDT001", date: DateTime.now().subtract(const Duration(hours: 2)), duration: const Duration(minutes: 45)),
    Procedure(id: "PCDT002", date: DateTime.now().subtract(const Duration(days: 1)), duration: const Duration(minutes: 30)),
    Procedure(id: "PCDT003", date: DateTime.now().subtract(const Duration(days: 3)), duration: const Duration(minutes: 60)),
  ];

  String searchQuery = "";
  bool sortAscending = false;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    List<Procedure> filtered = procedures
        .where((p) => p.id.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    filtered.sort((a, b) => sortAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A89D),
        title: const Text("Histórico procedimientos", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: () => _toggleSort(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: filtered.length,
          itemBuilder: (context, index, animation) {
            final p = filtered[index];
            return SizeTransition(
              sizeFactor: animation,
              child: _procedureCard(p),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00A89D),
        onPressed: _addNewProcedure,
        label: const Icon(Icons.add, color: Colors.deepPurple, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _procedureCard(Procedure p) {
    String formattedDate = "${p.date.year}/${p.date.month.toString().padLeft(2, '0')}/${p.date.day.toString().padLeft(2, '0')}";
    String time = "${p.date.hour.toString().padLeft(2, '0')}:${p.date.minute.toString().padLeft(2, '0')}";
    String duration = "${p.duration.inMinutes} min";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.id, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                onPressed: () => _editProcedure(p),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                onPressed: () => _copyProcedure(p),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                onPressed: () => _deleteProcedure(p),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text("$formattedDate, $time, $duration", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  void _toggleSort() {
    setState(() {
      sortAscending = !sortAscending;
    });
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Buscar por ID", style: TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => searchQuery = value),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "Ej: PCDT001", hintStyle: TextStyle(color: Colors.white54)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  void _addNewProcedure() {
    final newId = "PCDT00${procedures.length + 1}";
    final newProc = Procedure(id: newId, date: DateTime.now(), duration: const Duration(minutes: 40));
    setState(() {
      procedures.insert(0, newProc);
    });
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
  }

  void _editProcedure(Procedure p) {
    final index = procedures.indexOf(p);
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: p.id);
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text("Editar ID", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  procedures[index] = Procedure(
                    id: controller.text,
                    date: p.date,
                    duration: p.duration,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.tealAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  void _copyProcedure(Procedure p) {
    final newId = "${p.id}_COPY";
    final copy = Procedure(id: newId, date: DateTime.now(), duration: p.duration);
    setState(() {
      procedures.insert(0, copy);
    });
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
  }

  void _deleteProcedure(Procedure p) {
    final index = procedures.indexOf(p);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Eliminar procedimiento", style: TextStyle(color: Colors.white)),
        content: Text("Deseas eliminar ${p.id}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              final removed = procedures.removeAt(index);
              Navigator.pop(context);
              _listKey.currentState?.removeItem(
                index,
                    (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: _procedureCard(removed),
                ),
                duration: const Duration(milliseconds: 500),
              );
              setState(() {});
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }
}
