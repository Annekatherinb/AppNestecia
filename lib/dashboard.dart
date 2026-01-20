import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'profile.dart';
import 'history.dart';
import 'cusum.dart';
import 'Register.dart';

import 'ChatBotPage.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00A89D);

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),

      // ✅ Si NO quieres FAB, bórralo completo
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => setState(() => _tabIndex = 1),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Config",
          ),
        ],
      ),

      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: const [
            _HomeDashboard(),  // Inicio (solo Cusum/Histórico/Registro)
            ChatBotPage(),     // Chat
            SettingsPage(),    // Config
          ],
        ),
      ),
    );
  }
}

/// =======================
///     HOME (DASHBOARD)
/// =======================
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 700;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isWide: isWide),
              const SizedBox(height: 16),
              _buildMenuGrid(context, isWide: isWide),
              const SizedBox(height: 22),
              _buildResultsSection(),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isWide}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3DD),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _headerTextAndButton(context)),
          const SizedBox(width: 10),
          SizedBox(
            height: isWide ? 140 : 110,
            child: Image.asset(
              'assets/images/doctor.png',
              fit: BoxFit.contain,
            ),
          ),
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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Nombre Apellido",
          style: GoogleFonts.rubik(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 2),
        Text(
          "24 de Julio de 2025",
          style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(_fadeRoute(const ProfilePage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A89D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.person_outline),
          label: const Text("Ver perfil"),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context, {required bool isWide}) {
    // ✅ En celular: 2 columnas
    // ✅ En pantallas grandes: 3 columnas
    final crossAxisCount = isWide ? 3 : 2;

    final actions = [
      _ActionCard(
        icon: Icons.bar_chart,
        title: "Cusum",
        color: const Color(0xFF00BFA6),
        onTap: () => Navigator.of(context).push(_fadeRoute(const CusumPage())),
      ),
      _ActionCard(
        icon: Icons.history,
        title: "Histórico",
        color: const Color(0xFF2979FF),
        onTap: () => Navigator.of(context).push(_fadeRoute(const HistoryPage())),
      ),
      _ActionCard(
        icon: Icons.folder,
        title: "Registro",
        color: const Color(0xFFFF7043),
        onTap: () => Navigator.of(context).push(_fadeRoute(const RegistroPage())),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isWide ? 2.2 : 1.85,
      ),
      itemBuilder: (_, i) => actions[i],
    );
  }

  Widget _buildResultsSection() {
    final results = [
      _ResultItem(percent: 0.95, label: "95%", color: Colors.lightBlue),
      _ResultItem(percent: 0.10, label: "10%", color: Colors.redAccent),
      _ResultItem(percent: 0.50, label: "50%", color: Colors.deepPurple),
      _ResultItem(percent: 1.00, label: "100%", color: Colors.teal),
      _ResultItem(percent: 0.30, label: "30%", color: Colors.orange),
      _ResultItem(percent: 0.75, label: "75%", color: Colors.green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resultados",
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey[850],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: results.map((r) => _ResultCard(item: r)).toList(),
        ),
      ],
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// =======================
///       UI WIDGETS
/// =======================
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItem {
  final double percent;
  final String label;
  final Color color;

  _ResultItem({
    required this.percent,
    required this.label,
    required this.color,
  });
}

class _ResultCard extends StatelessWidget {
  final _ResultItem item;
  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 8,
            percent: item.percent.clamp(0.0, 1.0),
            center: Text(
              item.label,
              style: GoogleFonts.rubik(fontWeight: FontWeight.w800),
            ),
            progressColor: item.color,
            backgroundColor: const Color(0xFFBDBDBD),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }
}
