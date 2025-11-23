import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/project_model.dart';
import '../models/image_record_model.dart';
import '../models/analysis_model.dart';

/// Serviço para carregar dados de demonstração dos assets
/// Permite apresentar o app com exemplos sem depender do Firebase
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
      _demoProjects = projectsList.map((json) => ProjectModel.fromJson(json)).toList();

      // Carregar imagens
      final imagesJson = await rootBundle.loadString('assets/demo/data/image_records.json');
      final imagesList = json.decode(imagesJson) as List;
      
      // Substituir placeholders de base64 pelas imagens reais dos assets
      _demoImages = [];
      for (int i = 0; i < imagesList.length; i++) {
        final imageData = Map<String, dynamic>.from(imagesList[i]);
        
        // Carregar imagem do asset
        final imagePath = _getImagePath(i + 1);
        final imageBytes = await rootBundle.load(imagePath);
        final base64Image = base64Encode(imageBytes.buffer.asUint8List());
        
        // Substituir placeholders
        imageData['imageBase64'] = base64Image;
        imageData['imageUrl'] = 'data:image/jpeg;base64,$base64Image';
        imageData['thumbnailUrl'] = 'data:image/jpeg;base64,$base64Image';
        
        _demoImages!.add(ImageRecordModel.fromJson(imageData));
      }

      // Carregar análises
      final analysesJson = await rootBundle.loadString('assets/demo/data/analyses.json');
      final analysesList = json.decode(analysesJson) as List;
      _demoAnalyses = analysesList.map((json) => AnalysisModel.fromJson(json)).toList();

      _isLoaded = true;
      print('✅ Dados de demonstração carregados: ${_demoProjects!.length} projetos, ${_demoImages!.length} imagens, ${_demoAnalyses!.length} análises');
    } catch (e) {
      print('❌ Erro ao carregar dados de demonstração: $e');
      _demoProjects = [];
      _demoImages = [];
      _demoAnalyses = [];
    }
  }

  String _getImagePath(int index) {
    switch (index) {
      case 1:
        return 'assets/demo/images/obra1_fundacao.jpg';
      case 2:
        return 'assets/demo/images/obra2_estrutura.jpg';
      case 3:
        return 'assets/demo/images/obra3_alvenaria.jpg';
      case 4:
        return 'assets/demo/images/obra4_acabamento.jpg';
      default:
        return 'assets/demo/images/obra1_fundacao.jpg';
    }
  }

  /// Retorna todos os projetos de demonstração
  List<ProjectModel> get demoProjects => _demoProjects ?? [];

  /// Retorna todas as imagens de demonstração
  List<ImageRecordModel> get demoImages => _demoImages ?? [];

  /// Retorna todas as análises de demonstração
  List<AnalysisModel> get demoAnalyses => _demoAnalyses ?? [];

  /// Retorna imagens de um projeto específico
  List<ImageRecordModel> getImagesForProject(String projectId) {
    return _demoImages?.where((img) => img.projectId == projectId).toList() ?? [];
  }

  /// Retorna análise de uma imagem específica
  AnalysisModel? getAnalysisForImage(String imageId) {
    return _demoAnalyses?.firstWhere(
      (analysis) => analysis.imageRecordId == imageId,
      orElse: () => AnalysisModel(
        id: '',
        imageRecordId: '',
        projectId: '',
        analysisDate: DateTime.now(),
        status: 'pending',
      ),
    );
  }

  /// Verifica se os dados foram carregados
  bool get isLoaded => _isLoaded;
}
