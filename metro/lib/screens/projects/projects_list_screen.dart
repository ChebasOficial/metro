import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../../config/app_config.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  final bool showAppBar;
  
  const ProjectsListScreen({super.key, this.showAppBar = true});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  final _projectService = ProjectService();
  String _selectedFilter = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Todos os Projetos'),
        backgroundColor: AppConfig.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ) : null,
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(AppConfig.paddingNormal),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todos',
                    isSelected: _selectedFilter == 'todos',
                    onSelected: () => setState(() => _selectedFilter = 'todos'),
                  ),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _FilterChip(
                    label: 'Em Andamento',
                    isSelected: _selectedFilter == 'em_andamento',
                    onSelected: () => setState(() => _selectedFilter = 'em_andamento'),
                  ),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _FilterChip(
                    label: 'Pausado',
                    isSelected: _selectedFilter == 'pausado',
                    onSelected: () => setState(() => _selectedFilter = 'pausado'),
                  ),
                  const SizedBox(width: AppConfig.paddingSmall),
                  _FilterChip(
                    label: 'Concluído',
                    isSelected: _selectedFilter == 'concluido',
                    onSelected: () => setState(() => _selectedFilter = 'concluido'),
                  ),
                ],
              ),
            ),
          ),

          // Lista de Projetos
          Expanded(
            child: StreamBuilder<List<ProjectModel>>(
              stream: _selectedFilter == 'todos'
                  ? _projectService.getAllProjects()
                  : _projectService.getProjectsByStatus(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                List<ProjectModel> projects = snapshot.data ?? [];

                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.construction,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConfig.paddingNormal),
                        Text(
                          'Nenhum projeto encontrado',
                          style: TextStyle(
                            fontSize: AppConfig.textSizeMedium,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConfig.paddingNormal),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return _ProjectCard(project: projects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateProjectScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Projeto'),
        backgroundColor: AppConfig.primaryColor,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppConfig.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConfig.primaryColor,
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const _ProjectCard({required this.project});

  Color _getStatusColor() {
    switch (project.status) {
      case 'em_andamento':
        return AppConfig.successColor;
      case 'pausado':
        return AppConfig.warningColor;
      case 'concluido':
        return AppConfig.primaryColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (project.status) {
      case 'em_andamento':
        return 'Em Andamento';
      case 'pausado':
        return 'Pausado';
      case 'concluido':
        return 'Concluído';
      default:
        return project.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConfig.paddingNormal),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.paddingNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConfig.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConfig.radiusSmall),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        fontSize: AppConfig.textSizeSmall,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Início: ${_formatDate(project.startDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (project.expectedEndDate != null) ...[
                    const SizedBox(width: AppConfig.paddingNormal),
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Previsão: ${_formatDate(project.expectedEndDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

