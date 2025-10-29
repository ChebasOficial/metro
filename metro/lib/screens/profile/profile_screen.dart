import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_config.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Usuário não autenticado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.paddingNormal),
        child: Column(
          children: [
            // Avatar e Nome
            CircleAvatar(
              radius: 50,
              backgroundColor: AppConfig.primaryColor,
              child: Text(
                _getInitials(user.displayName ?? user.email ?? 'U'),
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppConfig.paddingNormal),
            Text(
              user.displayName ?? 'Usuário',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConfig.paddingSmall),
            Text(
              user.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (user.emailVerified)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Email Verificado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: AppConfig.paddingLarge),

            // Informações Pessoais
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Informações Pessoais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user.email ?? 'Não informado'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Telefone'),
                    subtitle: Text(user.phoneNumber ?? 'Não informado'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Membro desde'),
                    subtitle: Text(
                      user.metadata.creationTime != null
                          ? _formatDate(user.metadata.creationTime!)
                          : 'N/A',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Último acesso'),
                    subtitle: Text(
                      user.metadata.lastSignInTime != null
                          ? _formatDateTime(user.metadata.lastSignInTime!)
                          : 'N/A',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.paddingNormal),

            // Informações da Conta
            Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Informações da Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('ID do Usuário'),
                    subtitle: Text(user.uid),
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Provedor de Autenticação'),
                    subtitle: const Text('Email e Senha'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConfig.paddingNormal),

            // Ações
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Perfil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Alterar Senha'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Configurações'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  if (!user.emailVerified) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text('Verificar Email'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _sendVerificationEmail(context, user),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppConfig.paddingLarge),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendVerificationEmail(BuildContext context, User user) async {
    try {
      await user.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de verificação enviado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

