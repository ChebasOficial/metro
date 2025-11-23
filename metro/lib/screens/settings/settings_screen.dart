import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_config.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoAnalysis = true;
  String _imageQuality = 'high';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Seção: Notificações
          _buildSectionHeader('Notificações'),
          _buildSwitchTile(
            title: 'Ativar Notificações',
            subtitle: 'Receber alertas sobre análises e problemas',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            icon: Icons.notifications,
          ),

          const Divider(),

          // Seção: Análise de IA
          _buildSectionHeader('Análise de IA'),
          _buildSwitchTile(
            title: 'Análise Automática',
            subtitle: 'Processar imagens automaticamente com Gemini AI',
            value: _autoAnalysis,
            onChanged: (value) {
              setState(() => _autoAnalysis = value);
            },
            icon: Icons.psychology,
          ),

          const Divider(),

          // Seção: Captura de Imagens
          _buildSectionHeader('Captura de Imagens'),
          _buildDropdownTile(
            title: 'Qualidade da Imagem',
            subtitle: _getQualityLabel(_imageQuality),
            icon: Icons.photo_camera,
            value: _imageQuality,
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Baixa (Economiza espaço)')),
              DropdownMenuItem(value: 'medium', child: Text('Média (Recomendado)')),
              DropdownMenuItem(value: 'high', child: Text('Alta (Melhor qualidade)')),
            ],
            onChanged: (value) {
              setState(() => _imageQuality = value!);
            },
          ),

          const Divider(),

          // Seção: Aparência
          _buildSectionHeader('Aparência'),
          _buildSwitchTile(
            title: 'Modo Escuro',
            subtitle: 'Usar tema escuro no aplicativo',
            value: isDarkMode,
            onChanged: (value) {
              MyApp.of(context)?.toggleTheme();
            },
            icon: Icons.dark_mode,
          ),

          const Divider(),

          // Seção: Sobre
          _buildSectionHeader('Sobre'),
          _buildTile(
            title: 'Versão do App',
            subtitle: '1.0.0',
            icon: Icons.info_outline,
            onTap: () {},
          ),
          _buildTile(
            title: 'Termos de Uso',
            subtitle: 'Ler os termos de uso do aplicativo',
            icon: Icons.description,
            onTap: () {
              _showInfoDialog(
                'Termos de Uso',
                'Este aplicativo é fornecido "como está" para fins de monitoramento de obras. '
                'Ao usar este aplicativo, você concorda em utilizá-lo de forma responsável e ética.',
              );
            },
          ),
          _buildTile(
            title: 'Política de Privacidade',
            subtitle: 'Como tratamos seus dados',
            icon: Icons.privacy_tip,
            onTap: () {
              _showInfoDialog(
                'Política de Privacidade',
                'Seus dados são armazenados de forma segura no Firebase. '
                'Não compartilhamos suas informações com terceiros. '
                'As imagens capturadas são armazenadas apenas para fins de monitoramento.',
              );
            },
          ),

          const Divider(),

          // Seção: Conta
          _buildSectionHeader('Conta'),
          _buildTile(
            title: 'Sair',
            subtitle: 'Fazer logout do aplicativo',
            icon: Icons.logout,
            iconColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
          _buildTile(
            title: 'Excluir Conta',
            subtitle: 'Remover permanentemente sua conta',
            icon: Icons.delete_forever,
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(),
          ),

          const SizedBox(height: AppConfig.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConfig.paddingNormal,
        AppConfig.paddingLarge,
        AppConfig.paddingNormal,
        AppConfig.paddingSmall,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppConfig.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppConfig.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppConfig.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppConfig.primaryColor,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConfig.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  String _getQualityLabel(String quality) {
    switch (quality) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      default:
        return quality;
    }
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'ATENÇÃO: Esta ação é irreversível! Todos os seus dados serão permanentemente removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.delete();
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir conta: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

