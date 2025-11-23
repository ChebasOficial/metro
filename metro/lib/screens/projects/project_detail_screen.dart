import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../config/app_config.dart';
import '../../services/project_service.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  Future<void> _completeProject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Projeto'),
        content: const Text('Deseja marcar este projeto como concluído?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.successColor,
            ),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final projectService = ProjectService();
        await projectService.updateProjectStatus(project.id, 'concluido');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projeto concluído com sucesso!'),
              backgroundColor: AppConfig.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao concluir projeto: $e'),
              backgroundColor: AppConfig.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteProject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text(
          'Tem certeza que deseja excluir este projeto? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final projectService = ProjectService();
        await projectService.deleteProject(project.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projeto excluído com sucesso!'),
              backgroundColor: AppConfig.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir projeto: $e'),
              backgroundColor: AppConfig.errorColor,
            ),
          );
        }
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'em_andamento':
        return 'Em Andamento';
      case 'pausado':
        return 'Pausado';
      case 'concluido':
        return 'Concluído';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'em_andamento':
        return Colors.blue;
      case 'pausado':
        return Colors.orange;
      case 'concluido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        backgroundColor: AppConfig.primaryColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'complete') {
                _completeProject(context);
              } else if (value == 'delete') {
                _deleteProject(context);
              }
            },
            itemBuilder: (context) => [
              if (project.status != 'concluido')
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Concluir Projeto'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir Projeto'),
                  ],
                ),
              ),
            ],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConfig.paddingSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, size: 20, color: AppConfig.primaryColor),
                          const SizedBox(width: AppConfig.paddingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: AppConfig.textSizeSmall,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(project.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusLabel(project.status),
                                    style: TextStyle(
                                      fontSize: AppConfig.textSizeNormal,
                                      color: _getStatusColor(project.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Data de Início',
                      value: '${project.startDate.day}/${project.startDate.month}/${project.startDate.year}',
                    ),
                    if (project.expectedEndDate != null)
                      _InfoRow(
                        icon: Icons.event,
                        label: 'Previsão de Término',
                        value: '${project.expectedEndDate!.day}/${project.expectedEndDate!.month}/${project.expectedEndDate!.year}',
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
                      Navigator.of(context).pushNamed('/capture');
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
                      Navigator.of(context).pushNamed('/gallery');
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
                      Navigator.of(context).pushNamed('/alerts');
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
                      Navigator.of(context).pushNamed('/analyses');
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
                  fontWeight: FontWeight.w500,
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

