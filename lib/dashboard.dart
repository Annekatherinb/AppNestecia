import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'profile.dart';
import 'history.dart';
import 'cusum.dart';
import 'Register.dart';
import 'models/student.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, constraints),
                  const SizedBox(height: 24),
                  _buildMenuButtons(context, constraints),
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

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    final image = Image.asset(
      'assets/images/doctor.png',
      height: isWide ? 160 : 140,
      fit: BoxFit.contain,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3DD),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _headerTextAndButton(context)),
          const SizedBox(width: 16),
          image,
        ],
      )
          : Column(
        children: [
          _headerTextAndButton(context),
          const SizedBox(height: 16),
          image,
        ],
      ),
    );
  }

  Widget _headerTextAndButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenido, Doc",
          style: GoogleFonts.rubik(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Nombre Apellido\n24 de Julio de 2025",
          style: GoogleFonts.rubik(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(_fadeRoute(const ProfilePage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A89D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Ver perfil"),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context, BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    final buttons = [
      _menuButton(
        Icons.bar_chart,
        "Cusum",
        const Color(0xFF00BFA6),
            () {
          Navigator.of(context).push(_fadeRoute(const CusumPage()));
        },
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
      _menuButton(
        Icons.history,
        "Histórico",
        const Color(0xFF2979FF),
            () {
          Navigator.of(context).push(_fadeRoute(const HistoryPage()));
        },
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
      _menuButton(
        Icons.folder,
        "Registro",
        const Color(0xFFFF7043),
            () {
          Navigator.of(context).push(_fadeRoute(const RegistroPage()));
        },
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
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
        buttons[2],
      ],
    );
  }

  Widget _menuButton(
      IconData icon,
      String title,
      Color backgroundColor,
      VoidCallback onTap, {
        Color iconColor = Colors.black87,
        Color textColor = Colors.black87,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resultados",
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 8),
              _resultCircle(0.95, "95%", Colors.lightBlue),
              _resultCircle(0.10, "10%", Colors.redAccent),
              _resultCircle(0.50, "50%", Colors.deepPurple),
              _resultCircle(1.00, "100%", Colors.teal),
              _resultCircle(0.30, "30%", Colors.orange),
              _resultCircle(0.75, "75%", Colors.green),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultCircle(double percent, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CircularPercentIndicator(
        radius: 50.0,
        lineWidth: 10.0,
        percent: percent.clamp(0.0, 1.0),
        center: Text(label,
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            )),
        progressColor: color,
        backgroundColor: const Color(0xFFBDBDBD),
        circularStrokeCap: CircularStrokeCap.round,
      ),
    );
  }

  // Transición suave entre páginas
  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
