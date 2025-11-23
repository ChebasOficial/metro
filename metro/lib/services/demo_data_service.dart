import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/project_model.dart';
import '../models/image_record_model.dart';
import '../models/analysis_model.dart';

/// Serviço para carregar dados de demonstração dos assets
class DemoDataService {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal();

  List<ProjectModel>? _demoProjects;
  List<ImageRecordModel>? _demoImages;
  List<AnalysisModel>? _demoAnalyses;
  
  bool _isLoaded = false;

  /// Carrega todos os dados de demonstração dos assets
  Future<void> loadDemoData() async {
    if (_isLoaded) return;

    try {
      // Carregar projetos
      final projectsJson = await rootBundle.loadString('assets/demo/data/projects.json');
      final projectsList = json.decode(projectsJson) as List;
      _demoProjects = projectsList.map((json) {
        final data = json as Map<String, dynamic>;
        return ProjectModel(
          id: data['id'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          startDate: DateTime.parse(data['startDate']),
          expectedEndDate: data['expectedEndDate'] != null 
              ? DateTime.parse(data['expectedEndDate']) 
              : null,
          status: data['status'] ?? 'em_andamento',
          responsibleEngineers: List<String>.from(data['responsibleEngineers'] ?? []),
          bimData: data['bimData'],
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
          userId: data['userId'] ?? 'demo_user',
        );
      }).toList();

      // Carregar imagens
      final imagesJson = await rootBundle.loadString('assets/demo/data/image_records.json');
      final imagesList = json.decode(imagesJson) as List;
      
      _demoImages = [];
      for (int i = 0; i < imagesList.length; i++) {
        final imageData = Map<String, dynamic>.from(imagesList[i]);
        
        // Carregar imagem do asset
        final imagePath = _getImagePath(i + 1);
        final imageBytes = await rootBundle.load(imagePath);
        final base64Image = base64Encode(imageBytes.buffer.asUint8List());
        
        _demoImages!.add(ImageRecordModel(
          id: imageData['id'] ?? '',
          projectId: imageData['projectId'] ?? '',
          capturePointId: imageData['capturePointId'] ?? '',
          imageUrl: 'data:image/jpeg;base64,$base64Image',
          thumbnailUrl: 'data:image/jpeg;base64,$base64Image',
          captureDate: DateTime.parse(imageData['captureDate']),
          capturedBy: imageData['capturedBy'] ?? 'demo_user',
          capturedByName: imageData['capturedByName'] ?? 'Demo',
          latitude: imageData['latitude']?.toDouble(),
          longitude: imageData['longitude']?.toDouble(),
          analysisStatus: imageData['analysisStatus'] ?? 'completed',
          metadata: Map<String, dynamic>.from(imageData['metadata'] ?? {}),
          createdAt: DateTime.parse(imageData['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(imageData['updatedAt'] ?? DateTime.now().toIso8601String()),
        ));
      }

      // Carregar análises
      final analysesJson = await rootBundle.loadString('assets/demo/data/analyses.json');
      final analysesList = json.decode(analysesJson) as List;
      _demoAnalyses = analysesList.map((json) {
        final data = json as Map<String, dynamic>;
        return AnalysisModel(
          id: data['id'] ?? '',
          imageRecordId: data['imageRecordId'] ?? '',
          projectId: data['projectId'] ?? '',
          analysisDate: DateTime.parse(data['analysisDate']),
          status: data['status'] ?? 'completed',
          geminiResponse: Map<String, dynamic>.from(data['geminiResponse'] ?? {}),
          detectedElements: [], // Simplificado
          identifiedIssues: List<String>.from(data['identifiedIssues'] ?? []),
          progressEstimate: data['progressEstimate']?.toDouble() ?? 0.0,
          comparisonWithBIM: data['comparisonWithBIM'],
          deviations: data['deviations'] != null ? Map<String, dynamic>.from(data['deviations']) : null,
          createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      _isLoaded = true;
      print('✅ Dados demo: ${_demoProjects!.length} projetos, ${_demoImages!.length} imagens');
    } catch (e) {
      print('❌ Erro ao carregar dados demo: $e');
      _demoProjects = [];
      _demoImages = [];
      _demoAnalyses = [];
    }
  }

  String _getImagePath(int index) {
    switch (index) {
      case 1: return 'assets/demo/images/obra1_fundacao.jpg';
      case 2: return 'assets/demo/images/obra2_estrutura.jpg';
      case 3: return 'assets/demo/images/obra3_alvenaria.jpg';
      case 4: return 'assets/demo/images/obra4_acabamento.jpg';
      default: return 'assets/demo/images/obra1_fundacao.jpg';
    }
  }

  List<ProjectModel> get demoProjects => _demoProjects ?? [];
  List<ImageRecordModel> get demoImages => _demoImages ?? [];
  List<AnalysisModel> get demoAnalyses => _demoAnalyses ?? [];

  List<ImageRecordModel> getImagesForProject(String projectId) {
    return _demoImages?.where((img) => img.projectId == projectId).toList() ?? [];
  }

  AnalysisModel? getAnalysisForImage(String imageId) {
    try {
      return _demoAnalyses?.firstWhere((a) => a.imageRecordId == imageId);
    } catch (e) {
      return null;
    }
  }

  bool get isLoaded => _isLoaded;
}
