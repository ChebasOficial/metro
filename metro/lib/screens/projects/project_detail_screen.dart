import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../services/project_service.dart';
import '../../services/auth_service.dart';
import '../../config/app_config.dart';
import '../gallery/gallery_screen.dart';
import '../alerts/alerts_screen.dart';
import '../analyses/analyses_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _projectService = ProjectService();
  bool _isProcessing = false;

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus == 'pausado' ? 'Pausar Projeto' : 'Concluir Projeto'),
        content: Text(
          newStatus == 'pausado'
              ? 'Deseja pausar este projeto?'
              : 'Deseja marcar este projeto como concluído?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'pausado' ? Colors.orange : Colors.green,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        setState(() => _isProcessing = true);

        await _projectService.updateProjectStatus(widget.project.id, newStatus);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus == 'pausado'
                    ? 'Projeto pausado com sucesso!'
                    : 'Projeto concluído com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar projeto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _showMembersDialog() async {
    showDialog(
      context: context,
      builder: (context) => _MembersDialog(
        projectId: widget.project.id,
        projectService: _projectService,
      ),
    );
  }

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text(
          'Tem certeza que deseja excluir este projeto? Esta ação não pode ser desfeita e todas as imagens e análises associadas serão perdidas.',
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

    if (confirm == true && mounted) {
      try {
        setState(() => _isProcessing = true);

        await _projectService.deleteProject(widget.project.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projeto excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir projeto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'membros':
                  _showMembersDialog();
                  break;
                case 'pausar':
                  _updateStatus('pausado');
                  break;
                case 'concluir':
                  _updateStatus('concluido');
                  break;
                case 'deletar':
                  _deleteProject();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'membros',
                child: Row(
                  children: [
                    Icon(Icons.people, color: AppConfig.primaryColor),
                    SizedBox(width: 8),
                    Text('Gerenciar Membros'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              if (widget.project.status == 'em_andamento')
                const PopupMenuItem(
                  value: 'pausar',
                  child: Row(
                    children: [
                      Icon(Icons.pause_circle, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Pausar Projeto'),
                    ],
                  ),
                ),
              if (widget.project.status != 'concluido')
                const PopupMenuItem(
                  value: 'concluir',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Concluir Projeto'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'deletar',
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
                      value: widget.project.description,
                    ),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Localização',
                      value: widget.project.location,
                    ),
                    _InfoRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: _getStatusLabel(widget.project.status),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GalleryScreen(
                            projectId: widget.project.id,
                            projectName: widget.project.name,
                          ),
                        ),
                      );
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AlertsScreen(
                            projectId: widget.project.id,
                            projectName: widget.project.name,
                          ),
                        ),
                      );
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AnalysesScreen(
                            projectId: widget.project.id,
                            projectName: widget.project.name,
                          ),
                        ),
                      );
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

class _MembersDialog extends StatefulWidget {
  final String projectId;
  final ProjectService projectService;

  const _MembersDialog({
    required this.projectId,
    required this.projectService,
  });

  @override
  State<_MembersDialog> createState() => _MembersDialogState();
}

class _MembersDialogState extends State<_MembersDialog> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  List<Map<String, String>> _members = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    
    // Projetos demo não têm membros
    if (widget.projectId.startsWith('proj_')) {
      setState(() {
        _members = [];
        _isLoading = false;
      });
      return;
    }
    
    final members = await widget.projectService.getProjectMembers(widget.projectId);
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  Future<void> _addMember() async {
    // Verificar se é projeto demo
    if (widget.projectId.startsWith('proj_')) {
      _showMessage('Este é um projeto de demonstração. Crie um novo projeto para adicionar membros.');
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Digite um email válido');
      return;
    }

    setState(() => _isAdding = true);

    try {
      // Buscar usuário por email
      final user = await _authService.getUserByEmail(email);
      
      if (user == null) {
        _showMessage('Usuário não encontrado');
        setState(() => _isAdding = false);
        return;
      }

      // Verificar se já é membro
      if (_members.any((m) => m['id'] == user.id)) {
        _showMessage('Este usuário já é membro do projeto');
        setState(() => _isAdding = false);
        return;
      }

      // Adicionar ao projeto
      await widget.projectService.addMember(widget.projectId, user.id);
      
      _emailController.clear();
      _showMessage('${user.name} adicionado com sucesso!');
      await _loadMembers();
    } catch (e) {
      _showMessage('Erro ao adicionar membro: $e');
    }

    setState(() => _isAdding = false);
  }

  Future<void> _removeMember(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Membro'),
        content: Text('Deseja remover $userName do projeto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.projectService.removeMember(widget.projectId, userId);
        _showMessage('$userName removido com sucesso');
        await _loadMembers();
      } catch (e) {
        _showMessage('Erro ao remover membro: $e');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(AppConfig.paddingNormal),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConfig.radiusNormal),
                  topRight: Radius.circular(AppConfig.radiusNormal),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Membros do Projeto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Formulário para adicionar membro
            Padding(
              padding: const EdgeInsets.all(AppConfig.paddingNormal),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email do usuário',
                        hintText: 'usuario@exemplo.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isAdding,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isAdding ? null : _addMember,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Lista de membros
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _members.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppConfig.paddingLarge),
                            child: Text(
                              widget.projectId.startsWith('proj_')
                                  ? 'Este é um projeto de demonstração.\n\nCrie um novo projeto para adicionar membros e colaboradores.'
                                  : 'Nenhum membro adicionado.\n\nAdicione membros pelo email para compartilhar o projeto.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppConfig.primaryColor,
                                child: Text(
                                  member['name']!.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(member['name']!),
                              subtitle: Text(member['email']!),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeMember(
                                  member['id']!,
                                  member['name']!,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

