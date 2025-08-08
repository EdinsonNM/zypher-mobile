import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zypher/core/providers/theme_provider.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'dashboard/components/student_profile_card.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentStudent = studentProvider.currentStudent;

    String nombreCompleto = '';
    String grado = '';
    String? avatarUrl;

    if (currentStudent != null) {
      final student = currentStudent.student;
      final grade = currentStudent.grade;
      nombreCompleto = student.firstName;
      grado = '${grade.level.toString().split('.').last} / ${grade.name}';
      avatarUrl = student.thumbnail;
    }

    return Scaffold(
    
      body: ListView(
        children: [
          // Perfil real del estudiante
          StudentProfileCard(
            nombreCompleto: nombreCompleto,
            grado: grado,
            avatarUrl: avatarUrl,
          ),
          const SizedBox(height: 24),
          // Opciones
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(''),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Phone number'),
            subtitle: const Text('+51972705736'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('Manage Subscription'),
            subtitle: const Text('ChatGPT Plus'),
          ),
          ListTile(
            leading: const Icon(Icons.upgrade_outlined),
            title: const Text('Upgrade to Pro'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Personalization'),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Data Controls'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq_outlined),
            title: const Text('Voice'),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Security'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
          ),
          const Divider(),
          // Selector de tema
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Sistema'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Claro'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Oscuro'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 