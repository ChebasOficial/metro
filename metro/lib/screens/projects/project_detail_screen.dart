import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../config/app_config.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navegar para edição do projeto
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.paddingNormal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações Básicas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConfig.paddingNormal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Projeto',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.description,
                      label: 'Descrição',
                      value: project.description,
                    ),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Localização',
                      value: project.location,
                    ),
                    _InfoRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: project.status,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.paddingNormal),

            // Ações Rápidas
            Text(
              'Ações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConfig.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.camera_alt,
                    label: 'Capturar',
                    color: AppConfig.primaryColor,
                    onTap: () {
                      // TODO: Navegar para captura
                    },
                  ),
                ),
                const SizedBox(width: AppConfig.paddingSmall),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    color: AppConfig.secondaryColor,
                    onTap: () {
                      // TODO: Navegar para galeria
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.warning,
                    label: 'Alertas',
                    color: AppConfig.warningColor,
                    onTap: () {
                      // TODO: Navegar para alertas
                    },
                  ),
                ),
                const SizedBox(width: AppConfig.paddingSmall),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.analytics,
                    label: 'Análises',
                    color: AppConfig.accentColor,
                    onTap: () {
                      // TODO: Navegar para análises
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConfig.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConfig.primaryColor),
          const SizedBox(width: AppConfig.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppConfig.textSizeSmall,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppConfig.textSizeNormal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.paddingNormal),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: AppConfig.paddingSmall),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConfig.textSizeSmall,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

