import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'profile.dart';
import 'history.dart';
import 'cusum.dart';
import 'Register.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, constraints),
                  const SizedBox(height: 16),
                  _buildMenuButtons(context, constraints),
                  const SizedBox(height: 24),
                  _buildResultsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    final image = Image.asset(
      'assets/images/doctor.png',
      height: isWide ? 160 : 140,
      width: isWide ? 120 : null,
      fit: BoxFit.contain,
    );

    final text = _headerTextAndButton(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFA88600),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: constraints.maxWidth > 500
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: text),
          const SizedBox(width: 16),
          image,
        ],
      )
          : Column(
        children: [
          text,
          const SizedBox(height: 12),
          image,
        ],
      ),
    );
  }

  Widget _headerTextAndButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bienvenido, Doc",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text("Nombre Apellido\nFecha", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF00A89D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Perfil"),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    final buttons = [
      _menuButton(Icons.bar_chart, "Cusum", const Color(0xFF5C4432), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CusumPage()));
      }),
      _menuButton(Icons.history, "Historico", const Color(0xFF384957), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
      }),
      _menuButton(Icons.folder, "Registro", const Color(0xFF514073), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroPage()));
      }),
    ];

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons.map((b) => Expanded(child: b)).toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: buttons[0]),
            const SizedBox(width: 8),
            Expanded(child: buttons[1]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [Expanded(child: buttons[2])],
        ),
      ],
    );
  }

  Widget _menuButton(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("Resultados", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 8),
              _resultCircle(0.95, "95%", Colors.lightBlue),
              _resultCircle(0.10, "10%", Colors.redAccent),
              _resultCircle(0.50, "50%", Colors.lightBlue),
              _resultCircle(1.00, "100%", Colors.red),
              _resultCircle(0.30, "30%", Colors.greenAccent),
              _resultCircle(0.75, "75%", Colors.orange),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultCircle(double percent, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CircularPercentIndicator(
        radius: 50.0,
        lineWidth: 10.0,
        percent: percent.clamp(0.0, 1.0),
        center: Text(label, style: const TextStyle(color: Colors.white)),
        progressColor: color,
        backgroundColor: Colors.black54,
        circularStrokeCap: CircularStrokeCap.round,
      ),
    );
  }
}
