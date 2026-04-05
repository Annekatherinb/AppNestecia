import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true;
  bool haptics = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00A89D);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: Text(
          "Configuración",
          style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          _ProfileCard(
            name: "Nombre Apellido",
            role: "Docente / Residente",
            email: "correo@dominio.com",
            onEdit: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Editar perfil (demo)")),
              );
            },
          ),
          const SizedBox(height: 14),

          const _SectionTitle("Cuenta"),
          _SettingsTile(
            icon: Icons.person_outline,
            title: "Perfil",
            subtitle: "Ver y editar información",
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: "Seguridad",
            subtitle: "Cambiar contraseña y sesión",
            onTap: () {},
          ),

          const SizedBox(height: 12),
          const _SectionTitle("Aplicación"),

          _SwitchTile(
            icon: Icons.notifications_none,
            title: "Notificaciones",
            subtitle: "Recordatorios y alertas",
            value: notif,
            onChanged: (v) => setState(() => notif = v),
          ),
          _SwitchTile(
            icon: Icons.vibration,
            title: "Haptics",
            subtitle: "Vibración al tocar",
            value: haptics,
            onChanged: (v) => setState(() => haptics = v),
          ),
          _SwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Modo oscuro",
            subtitle: "Tema oscuro (solo UI)",
            value: darkMode,
            onChanged: (v) => setState(() => darkMode = v),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: "Idioma",
            subtitle: "Español",
            onTap: () {},
          ),

          const SizedBox(height: 12),
          const _SectionTitle("Soporte"),
          _SettingsTile(
            icon: Icons.help_outline,
            title: "Ayuda",
            subtitle: "Preguntas frecuentes",
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.bug_report_outlined,
            title: "Reportar un problema",
            subtitle: "Enviar feedback",
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: "Acerca de",
            subtitle: "Versión 1.0.0",
            onTap: () {},
          ),

          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cerrar sesión (demo)")),
              );
              // TODO: aquí haces logout real y vuelves a Login
              // Navigator.pushAndRemoveUntil(...);
            },
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar sesión"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.name,
    required this.role,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF00A89D);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primary.withOpacity(0.15),
            child: const Icon(Icons.person, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF00A89D)),
        title: Text(
          title,
          style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey[700]),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFF00A89D)),
        title: Text(
          title,
          style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.rubik(fontSize: 12, color: Colors.grey[700]),
        ),
        activeThumbColor: const Color(0xFF00A89D),
      ),
    );
  }
}
