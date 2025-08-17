import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zypher/core/providers/theme_provider.dart';
import 'package:zypher/core/providers/student_provider.dart';
import 'package:zypher/services/supabase_service.dart';
import 'package:zypher/core/constants/theme_colors.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await SupabaseService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(theme),
      body: SafeArea(
        child: Column(
          children: [
       
            // Contenido principal
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Gestionar Cuenta
                    _buildOptionCard(
                      icon: Icons.account_circle,
                      title: 'Gestionar Cuenta',
                      onTap: () {
                        // TODO: Implementar gestión de cuenta
                      },
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Apariencia
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardBackground(theme),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeColors.getCardBorder(theme),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apariencia',
                            style: TextStyle(
                              color: ThemeColors.getSecondaryText(theme),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildThemeSelector(themeProvider, theme),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Ayuda y Soporte
                    Container(
                      decoration: BoxDecoration(
                        color: ThemeColors.getCardBackground(theme),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeColors.getCardBorder(theme),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildOptionCard(
                            icon: Icons.help_outline,
                            title: 'Ayuda y Soporte',
                            onTap: () {
                              // TODO: Implementar ayuda y soporte
                            },
                            showBorder: true,
                            theme: theme,
                          ),
                          _buildOptionCard(
                            icon: Icons.info_outline,
                            title: 'Acerca de',
                            onTap: () {
                              // TODO: Implementar acerca de
                            },
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Botón de cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _signOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red[400],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout),
                            const SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showBorder = false,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(theme),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.getCardBorder(theme),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: showBorder
                  ? Border(
                      bottom: BorderSide(
                        color: ThemeColors.getDivider(theme),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ThemeColors.getSecondaryText(theme),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: ThemeColors.getPrimaryText(theme),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ThemeColors.getSecondaryText(theme),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBorder(theme),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildThemeOption(
            'Claro',
            ThemeMode.light,
            themeProvider.themeMode == ThemeMode.light,
            () => themeProvider.setThemeMode(ThemeMode.light),
            theme,
          ),
          _buildThemeOption(
            'Oscuro',
            ThemeMode.dark,
            themeProvider.themeMode == ThemeMode.dark,
            () => themeProvider.setThemeMode(ThemeMode.dark),
            theme,
          ),
          _buildThemeOption(
            'Sistema',
            ThemeMode.system,
            themeProvider.themeMode == ThemeMode.system,
            () => themeProvider.setThemeMode(ThemeMode.system),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String label,
    ThemeMode mode,
    bool isActive,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? ThemeColors.accentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : ThemeColors.getSecondaryText(theme),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
} 