import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_config.dart';
import '../../services/project_service.dart';
import '../../models/project_model.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _projectService = ProjectService();
  
  bool _isLoading = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Pegar o userId do usuário logado
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não está logado');
      }

      print('=== CRIANDO PROJETO ===');
      print('Nome: ${_nameController.text.trim()}');
      print('UserId: ${currentUser.uid}');
      
      ProjectModel newProject = ProjectModel(
        id: '',
        userId: currentUser.uid,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        startDate: _startDate,
        expectedEndDate: _endDate,
        status: 'em_andamento',
        responsibleEngineers: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final projectId = await _projectService.createProject(newProject);
      print('✅ Projeto criado com ID: $projectId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto criado com sucesso!'),
            backgroundColor: AppConfig.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Erro ao criar projeto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar projeto: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Projeto'),
        backgroundColor: AppConfig.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConfig.paddingNormal),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Projeto',
                prefixIcon: Icon(Icons.construction),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o nome do projeto';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.paddingNormal),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite a descrição do projeto';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.paddingNormal),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localização',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite a localização do projeto';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConfig.paddingNormal),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data de Início'),
              subtitle: Text(
                '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Data Prevista de Término'),
              subtitle: Text(
                _endDate != null
                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                    : 'Não definida',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                  firstDate: _startDate,
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const SizedBox(height: AppConfig.paddingLarge),
            ElevatedButton(
              onPressed: _isLoading ? null : _createProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Criar Projeto',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

