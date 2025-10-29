import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Usuário não autenticado'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.paddingNormal),
      child: Column(
        children: [
          // Avatar e Nome
          CircleAvatar(
            radius: 50,
            backgroundColor: AppConfig.primaryColor,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(
                    _getInitials(user.displayName ?? user.email ?? 'U'),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppConfig.paddingNormal),
          Text(
            user.displayName ?? 'Usuário',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            user.email ?? 'Email não disponível',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConfig.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.paddingNormal,
              vertical: AppConfig.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: user.emailVerified
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConfig.radiusLarge),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.emailVerified ? Icons.verified : Icons.warning,
                  size: 16,
                  color: user.emailVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  user.emailVerified
                      ? 'EMAIL VERIFICADO'
                      : 'EMAIL NÃO VERIFICADO',
                  style: TextStyle(
                    color: user.emailVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConfig.paddingLarge),

          // Informações do Perfil
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user.email ?? 'Não informado'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Telefone'),
                  subtitle: Text(user.phoneNumber ?? 'Não informado'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Membro desde'),
                  subtitle: Text(
                    user.metadata.creationTime != null
                        ? _formatDate(user.metadata.creationTime!)
                        : 'N/A',
                  ),
                ),
                const Divider(height: 1),
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
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('ID do Usuário'),
                  subtitle: Text(
                    user.uid,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Provedor de Autenticação'),
                  subtitle: Text(
                    _getProviderName(user.providerData),
                  ),
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
                    _showEditProfileDialog(context, user);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Alterar Senha'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                if (!user.emailVerified) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Verificar Email'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
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
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getProviderName(List<UserInfo> providers) {
    if (providers.isEmpty) return 'Desconhecido';

    final provider = providers.first.providerId;
    switch (provider) {
      case 'password':
        return 'Email e Senha';
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'phone':
        return 'Telefone';
      default:
        return provider;
    }
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.displayName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await user.updateDisplayName(nameController.text);
                await user.reload();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar perfil: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('As senhas não coincidem!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser!;
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );

                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPasswordController.text);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha alterada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao alterar senha: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }
}
