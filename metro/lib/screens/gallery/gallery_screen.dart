import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../services/image_service.dart';
import '../../services/gemini_service.dart';
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
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  Text(
                    'Nenhuma imagem encontrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppConfig.paddingSmall),
                  Text(
                    'Capture imagens para vê-las aqui',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
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

  const _ImageCard({
    required this.image,
    required this.imageService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ImageDetailScreen(image: image),
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

class _ImageDetailScreen extends StatefulWidget {
  final ImageRecordModel image;

  const _ImageDetailScreen({required this.image});

  @override
  State<_ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<_ImageDetailScreen> {
  final _imageService = ImageService();
  final _geminiService = GeminiService();
  bool _isProcessing = false;

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
            onPressed: _deleteImage,
            tooltip: 'Deletar imagem',
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
                    _formatDate(widget.image.captureDate),
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  _buildInfoRow(
                    Icons.person,
                    'Capturado por',
                    widget.image.capturedByName,
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  _buildInfoRow(
                    Icons.analytics,
                    'Status da Análise',
                    _getStatusLabel(widget.image.analysisStatus),
                  ),
                  const SizedBox(height: AppConfig.paddingNormal),
                  // Mostrar motivo da falha se houver
                  if (widget.image.analysisStatus == 'failed' && 
                      widget.image.metadata != null && 
                      widget.image.metadata!['error'] != null)
                    Container(
                      padding: const EdgeInsets.all(AppConfig.paddingNormal),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(AppConfig.radiusNormal),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: AppConfig.paddingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Motivo da Falha:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.image.metadata!['error'],
                                  style: TextStyle(color: Colors.red[900]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.image.latitude != null && widget.image.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppConfig.paddingNormal),
                      child: _buildInfoRow(
                        Icons.location_on,
                        'Localização',
                        '${widget.image.latitude}, ${widget.image.longitude}',
                      ),
                    ),
                  // Botões de ação
                  const SizedBox(height: AppConfig.paddingLarge),
                  if (widget.image.analysisStatus == 'failed' || 
                      widget.image.analysisStatus == 'pending')
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _reprocessAnalysis,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isProcessing ? 'Processando...' : 'Reprocessar Análise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Imagem'),
        content: const Text('Tem certeza que deseja deletar esta imagem? Esta ação não pode ser desfeita.'),
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
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Extrair imageId da imageUrl
        String imageId = widget.image.imageUrl;
        if (imageId.startsWith('data:image')) {
          // Se for data URI, usar o ID do registro
          imageId = widget.image.id;
        }

        await _imageService.deleteImage(widget.image.id, imageId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagem deletada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar imagem: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _reprocessAnalysis() async {
    setState(() => _isProcessing = true);

    try {
      // Atualizar status para processing
      await _imageService.updateAnalysisStatus(
        widget.image.id,
        'processing',
      );

      // Executar análise
      await _geminiService.analyzeConstructionImage(
        widget.image.id,
        widget.image.imageUrl,
        widget.image.projectId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Análise concluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Erro ao reprocessar: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildImage() {
    try {
      if (widget.image.imageUrl.startsWith('data:image')) {
        final base64String = widget.image.imageUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
        );
      } else {
        return Image.network(
          widget.image.imageUrl,
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

