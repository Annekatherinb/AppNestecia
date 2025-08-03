import 'package:flutter/material.dart';

class Procedure {
  final String id;
  final DateTime date;
  final Duration duration;
  final String tipo;

  Procedure({
    required this.id,
    required this.date,
    required this.duration,
    required this.tipo,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Procedure> procedures = [
    Procedure(
      id: "PCDT001",
      date: DateTime.now().subtract(const Duration(hours: 2)),
      duration: const Duration(minutes: 45),
      tipo: "Intubación orotraqueal",
    ),
    Procedure(
      id: "PCDT002",
      date: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(minutes: 30),
      tipo: "Máscara laríngea",
    ),
    Procedure(
      id: "PCDT003",
      date: DateTime.now().subtract(const Duration(days: 3)),
      duration: const Duration(minutes: 60),
      tipo: "Anestesia subaracnoidea",
    ),
  ];

  String searchQuery = "";
  bool sortAscending = false;

  final List<String> tipos = [
    "Intubación orotraqueal",
    "Intubación nasotraqueal",
    "Máscara laríngea",
    "Anestesia subaracnoidea",
  ];

  @override
  Widget build(BuildContext context) {
    List<Procedure> filtered = procedures
        .where((p) => p.id.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00205B),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFFF9F9F9),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF387EF6),
          title: const Text(
            "Histórico de procedimientos",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: _toggleSort,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: _buildGroupedProcedures(filtered),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("Nuevo"),
          onPressed: _addNewProcedure,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _toggleSort() {
    setState(() {
      sortAscending = !sortAscending;
    });
  }

  List<Widget> _buildGroupedProcedures(List<Procedure> procedures) {
    Map<String, List<Procedure>> grouped = {};

    for (var p in procedures) {
      grouped.putIfAbsent(p.tipo, () => []).add(p);
    }

    final List<Widget> widgets = [];

    grouped.forEach((tipo, lista) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            tipo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00205B),
            ),
          ),
        ),
      );

      lista.sort((a, b) =>
      sortAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));

      widgets.addAll(lista.map((p) => _procedureCard(p)).toList());
    });

    return widgets;
  }

  Widget _procedureCard(Procedure p) {
    String formattedDate =
        "${p.date.year}/${p.date.month.toString().padLeft(2, '0')}/${p.date.day.toString().padLeft(2, '0')}";
    String time =
        "${p.date.hour.toString().padLeft(2, '0')}:${p.date.minute.toString().padLeft(2, '0')}";
    String duration = "${p.duration.inMinutes} min";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF00205B),
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(
          p.id,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Fecha: $formattedDate\nHora: $time · Duración: $duration"),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editProcedure(p);
            if (value == 'copy') _copyProcedure(p);
            if (value == 'delete') _deleteProcedure(p);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'copy', child: Text('Duplicar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buscar por ID"),
        content: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: const InputDecoration(hintText: "Ej: PCDT001"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
    );
  }

  void _addNewProcedure() {
    String selectedTipo = tipos[0];
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo procedimiento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "ID del procedimiento"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTipo,
              items: tipos
                  .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                  .toList(),
              onChanged: (value) => selectedTipo = value!,
              decoration: const InputDecoration(labelText: "Tipo de procedimiento"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (idController.text.isNotEmpty) {
                setState(() {
                  procedures.insert(
                    0,
                    Procedure(
                      id: idController.text,
                      date: DateTime.now(),
                      duration: const Duration(minutes: 40),
                      tipo: selectedTipo,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProcedure(Procedure p) {
    final index = procedures.indexOf(p);
    final controller = TextEditingController(text: p.id);
    String selectedTipo = p.tipo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar procedimiento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "ID"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTipo,
              items: tipos
                  .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                  .toList(),
              onChanged: (value) => selectedTipo = value!,
              decoration: const InputDecoration(labelText: "Tipo de procedimiento"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                procedures[index] = Procedure(
                  id: controller.text,
                  date: p.date,
                  duration: p.duration,
                  tipo: selectedTipo,
                );
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _copyProcedure(Procedure p) {
    setState(() {
      procedures.insert(
        0,
        Procedure(
          id: "${p.id}_COPY",
          date: DateTime.now(),
          duration: p.duration,
          tipo: p.tipo,
        ),
      );
    });
  }

  void _deleteProcedure(Procedure p) {
    final index = procedures.indexOf(p);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar procedimiento"),
        content: Text("¿Deseas eliminar ${p.id}?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                procedures.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }
}
