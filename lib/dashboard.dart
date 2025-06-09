import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
            double horizontalPadding = constraints.maxWidth > 600 ? 32 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(constraints),
                  const SizedBox(height: 16),
                  _buildMenuButtons(constraints),
                  const SizedBox(height: 32),
                  _buildResultsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BoxConstraints constraints) {
    bool isWide = constraints.maxWidth > 600;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA88600),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Bienvenido, doc",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Nombre\nFecha", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00A89D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Perfil"),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/doctor.png',
              height: 160,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Bienvenido, doc",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Nombre\nFecha", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF00A89D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Perfil"),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/doctor.png',
              height: 160,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BoxConstraints constraints) {
    bool isWide = constraints.maxWidth > 600;

    return isWide
        ? Row(
      children: [
        _expandedMenuButton(Icons.bar_chart, "Cusum", const Color(0xFF5C4432)),
        _expandedMenuButton(Icons.history, "Historico", const Color(0xFF384957)),
        _expandedMenuButton(Icons.folder, "Registro", const Color(0xFF514073)),
      ],
    )
        : Column(
      children: [
        Row(
          children: [
            _expandedMenuButton(Icons.bar_chart, "Cusum", const Color(0xFF5C4432)),
            _expandedMenuButton(Icons.history, "Historico", const Color(0xFF384957)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _expandedMenuButton(Icons.folder, "Registro", const Color(0xFF514073)),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _expandedMenuButton(IconData icon, String title, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Resultados", style: TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 0.95,
                center: Text("95%", style: TextStyle(color: Colors.white)),
                progressColor: Colors.lightBlue,
                backgroundColor: Colors.black54,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 0.10,
                center: Text("10%", style: TextStyle(color: Colors.white)),
                progressColor: Colors.redAccent,
                backgroundColor: Colors.black54,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 0.50,
                center: Text("50%", style: TextStyle(color: Colors.white)),
                progressColor: Colors.lightBlue,
                backgroundColor: Colors.black54,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              CircularPercentIndicator(
                radius: 50.0,
                lineWidth: 10.0,
                percent: 1.0,
                center: Text("100%", style: TextStyle(color: Colors.white)),
                progressColor: Colors.red,
                backgroundColor: Colors.black54,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final int percent;
  final Color color;

  const _ProgressCircle(this.percent, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text("$percent%", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
