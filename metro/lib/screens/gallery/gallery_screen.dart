import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/image_service.dart';
import '../../models/image_record_model.dart';
import 'dart:convert';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ImageRecordModel>>(
        stream: _imageService.getAllImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar imagens: ${snapshot.error}'),
                ],
              ),
            );
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma imagem encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppConfig.paddingNormal),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConfig.paddingNormal,
              mainAxisSpacing: AppConfig.paddingNormal,
              childAspectRatio: 1,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _ImageCard(
                image: images[index],
                imageService: _imageService,
                onDeleted: () {
                  // Callback para atualizar a lista após exclusão
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final ImageRecordModel image;
  final ImageService imageService;
  final VoidCallback onDeleted;

  const _ImageCard({
    required this.image,
    required this.imageService,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ImageDetailScreen(
              image: image,
              imageService: imageService,
              onDeleted: onDeleted,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem
            _buildImage(),

            // Overlay com informações
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(image.captureDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      image.capturedByName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Badge de status da análise
            Positioned(
              top: 8,
              right: 8,
              child: _buildStatusBadge(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    try {
      // Se a imageUrl é Base64 (data URI)
      if (image.imageUrl.startsWith('data:image')) {
        final base64String = image.imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        );
      }
      // Se imageBase64 está disponível no modelo
      else if (image.imageBase64 != null && image.imageBase64!.isNotEmpty) {
        return Image.memory(
          base64Decode(image.imageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        );
      }
      // Se for um ID (formato antigo), buscar do Firestore
      else if (image.imageUrl.startsWith('img_')) {
        return FutureBuilder<String?>(
          future: imageService.getImageBase64(image.imageUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                base64Decode(snapshot.data!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorWidget(),
              );
            }
            return _buildErrorWidget();
          },
        );
      }
      // Se for URL HTTP/HTTPS
      else if (image.imageUrl.startsWith('http')) {
        return Image.network(
          image.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        );
      }
      // Formato desconhecido
      else {
        return _buildErrorWidget();
      }
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;

    switch (image.analysisStatus) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'processing':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ImageDetailScreen extends StatelessWidget {
  final ImageRecordModel image;
  final ImageService imageService;
  final VoidCallback onDeleted;

  const _ImageDetailScreen({
    required this.image,
    required this.imageService,
    required this.onDeleted,
  });

  Future<void> _deleteImage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Imagem'),
        content: const Text(
          'Tem certeza que deseja excluir esta imagem? Esta ação não pode ser desfeita.',
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
        // Extrair imageId se for formato antigo
        String? imageId;
        if (image.imageUrl.startsWith('img_')) {
          imageId = image.imageUrl;
        }

        // Deletar imagem
        final success = await imageService.deleteImage(image.id, imageId ?? image.id);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imagem excluída com sucesso!'),
                backgroundColor: AppConfig.successColor,
              ),
            );
            onDeleted();
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao excluir imagem'),
                backgroundColor: AppConfig.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir imagem: $e'),
              backgroundColor: AppConfig.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Imagem'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteImage(context),
            tooltip: 'Excluir imagem',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem grande
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(),
            ),

            // Informações
            Padding(
              padding: const EdgeInsets.all(AppConfig.paddingNormal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Data de Captura',
                    _formatDate(image.captureDate),
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  _buildInfoRow(
                    Icons.person,
                    'Capturado por',
                    image.capturedByName,
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  _buildInfoRow(
                    Icons.analytics,
                    'Status da Análise',
                    _getStatusLabel(image.analysisStatus),
                  ),
                  if (image.latitude != null && image.longitude != null) ...[
                    const SizedBox(height: AppConfig.paddingNormal),
                    _buildInfoRow(
                      Icons.location_on,
                      'Localização',
                      '${image.latitude}, ${image.longitude}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    try {
      if (image.imageUrl.startsWith('data:image')) {
        final base64String = image.imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
        );
      } else if (image.imageBase64 != null && image.imageBase64!.isNotEmpty) {
        return Image.memory(
          base64Decode(image.imageBase64!),
          fit: BoxFit.cover,
        );
      } else if (image.imageUrl.startsWith('img_')) {
        return FutureBuilder<String?>(
          future: imageService.getImageBase64(image.imageUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                base64Decode(snapshot.data!),
                fit: BoxFit.cover,
              );
            }
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            );
          },
        );
      } else {
        return Image.network(
          image.imageUrl,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Concluída';
      case 'processing':
        return 'Processando';
      case 'failed':
        return 'Falhou';
      default:
        return 'Pendente';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

