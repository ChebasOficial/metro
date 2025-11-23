import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../config/app_config.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? currentUser;

  const ProfileScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.paddingNormal),
      child: Column(
        children: [
          // Avatar e Nome
          CircleAvatar(
            radius: 50,
            backgroundColor: AppConfig.primaryColor,
            child: Text(
              currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppConfig.paddingNormal),
          Text(
            currentUser?.name ?? 'Usuário',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currentUser?.email ?? '',
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
              color: AppConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConfig.radiusLarge),
            ),
            child: Text(
              currentUser?.role.toUpperCase() ?? 'VISUALIZADOR',
              style: const TextStyle(
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppConfig.paddingLarge),

          // Informações do Perfil
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Telefone'),
                  subtitle: Text(currentUser?.phone ?? 'Não informado'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Membro desde'),
                  subtitle: Text(
                    currentUser != null
                        ? _formatDate(currentUser!.createdAt)
                        : 'N/A',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Último acesso'),
                  subtitle: Text(
                    currentUser?.lastLoginAt != null
                        ? _formatDate(currentUser!.lastLoginAt!)
                        : 'N/A',
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
                    Navigator.of(context).pushNamed('/edit-profile');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Alterar Senha'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushNamed('/change-password');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Configurações'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

