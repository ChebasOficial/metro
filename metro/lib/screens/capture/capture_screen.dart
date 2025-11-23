import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/app_config.dart';
import '../../services/image_service.dart';
import '../../services/project_service.dart';
import '../../models/project_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _imageService = ImageService();
  final _projectService = ProjectService();
  final _picker = ImagePicker();
  
  dynamic _selectedImage; // File no mobile, XFile na web
  XFile? _selectedImageFile;
  ProjectModel? _selectedProject;
  String? _selectedProjectId;
  String? _selectedCapturePoint;
  final _descriptionController = TextEditingController();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma imagem')),
      );
      return;
    }

    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um projeto')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Converter imagem para Base64
      final bytes = await _selectedImageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Salvar imagem usando o método uploadImage
      await _imageService.uploadImage(
        projectId: _selectedProject!.id,
        capturePointId: _selectedCapturePoint ?? 'default',
        imageBase64: base64Image,
        notes: _descriptionController.text.trim(),
        capturedBy: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem enviada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Imagem'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.paddingNormal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview da imagem
            if (_selectedImageFile != null)
              kIsWeb
                  ? FutureBuilder<Uint8List>(
                      future: _selectedImageFile!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
                              image: DecorationImage(
                                image: MemoryImage(snapshot.data!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
                        image: DecorationImage(
                          image: FileImage(_selectedImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: AppConfig.paddingNormal),
                    Text(
                      'Nenhuma imagem selecionada',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppConfig.paddingNormal),

            // Botões de captura
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppConfig.paddingNormal),
                    ),
                  ),
                ),
                const SizedBox(width: AppConfig.paddingNormal),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppConfig.paddingNormal),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConfig.paddingLarge),

            // Seleção de projeto
            StreamBuilder<List<ProjectModel>>(
              stream: _projectService.getAllProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConfig.paddingNormal),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text('Erro ao carregar projetos: ${snapshot.error}');
                }

                final projects = snapshot.data ?? [];

                if (projects.isEmpty) {
                  return Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(AppConfig.paddingNormal),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700]),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum projeto encontrado',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crie um projeto primeiro',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Projeto',
                    border: OutlineInputBorder(),
                  ),
                  items: projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Text(project.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                      _selectedProject = projects.firstWhere(
                        (p) => p.id == value,
                      );
                    });
                  },
                );
              },
            ),

            const SizedBox(height: AppConfig.paddingNormal),

            // Ponto de captura
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Ponto de Captura (opcional)',
                hintText: 'Ex: Pilar A1, Laje 3º andar',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _selectedCapturePoint = value,
            ),

            const SizedBox(height: AppConfig.paddingNormal),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva o que está sendo fotografado',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: AppConfig.paddingLarge),

            // Botão de enviar
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(AppConfig.paddingNormal),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Enviar Imagem',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

