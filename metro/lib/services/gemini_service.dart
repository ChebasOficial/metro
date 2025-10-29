import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_model.dart';
import '../models/image_record_model.dart';

class GeminiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // TODO: Mover para variável de ambiente

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  // Analisar imagem de obra
  Future<AnalysisModel?> analyzeConstructionImage(
    String imageRecordId,
    String imageUrl,
    String projectId, {
    String? constructionPhase,
    Map<String, dynamic>? bimData,
  }) async {
    try {
      // Baixar imagem
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      
      // Converter para Uint8List
      final List<int> bytesList = await response.fold<List<int>>(
        [],
        (previous, element) => previous..addAll(element),
      );
      final Uint8List imageBytes = Uint8List.fromList(bytesList);

      // Preparar prompt
      String prompt = _buildAnalysisPrompt(constructionPhase, bimData);

      // Enviar para Gemini AI
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final geminiResponse = await _model.generateContent(content);
      
      if (geminiResponse.text == null) {
        throw Exception('Resposta vazia da Gemini AI');
      }

      // Processar resposta
      AnalysisModel analysis = _processGeminiResponse(
        imageRecordId,
        projectId,
        geminiResponse.text!,
      );

      // Salvar análise no Firestore
      String analysisId = await _saveAnalysis(analysis);

      // Atualizar registro de imagem
      await _firestore.collection('image_records').doc(imageRecordId).update({
        'analysisStatus': 'completed',
        'analysisId': analysisId,
        'updatedAt': Timestamp.now(),
      });

      return analysis;
    } catch (e) {
      debugPrint('Erro ao analisar imagem: $e');
      
      // Atualizar status como falho
      await _firestore.collection('image_records').doc(imageRecordId).update({
        'analysisStatus': 'failed',
        'updatedAt': Timestamp.now(),
      });
      
      return null;
    }
  }

  // Construir prompt para análise
  String _buildAnalysisPrompt(String? phase, Map<String, dynamic>? bimData) {
    StringBuffer prompt = StringBuffer();
    
    prompt.writeln('Você é um especialista em análise de obras de construção civil, especialmente obras de metrô.');
    prompt.writeln('Analise esta imagem de canteiro de obras e forneça as seguintes informações em formato JSON:');
    prompt.writeln();
    prompt.writeln('1. Elementos detectados (tipo, descrição, confiança)');
    prompt.writeln('2. Problemas ou irregularidades identificadas');
    prompt.writeln('3. Estimativa de progresso da obra (0-100%)');
    prompt.writeln('4. Estado geral da construção');
    
    if (phase != null) {
      prompt.writeln();
      prompt.writeln('Fase da obra esperada: $phase');
    }
    
    if (bimData != null) {
      prompt.writeln();
      prompt.writeln('Dados do projeto BIM para comparação:');
      prompt.writeln(bimData.toString());
    }
    
    prompt.writeln();
    prompt.writeln('Formato de resposta esperado (JSON):');
    prompt.writeln('{');
    prompt.writeln('  "detectedElements": [');
    prompt.writeln('    {"type": "pilar", "description": "...", "confidence": 0.95}');
    prompt.writeln('  ],');
    prompt.writeln('  "identifiedIssues": ["..."],');
    prompt.writeln('  "progressEstimate": 75.5,');
    prompt.writeln('  "generalState": "...",');
    prompt.writeln('  "comparisonWithBIM": "..."');
    prompt.writeln('}');
    
    return prompt.toString();
  }

  // Processar resposta da Gemini
  AnalysisModel _processGeminiResponse(
    String imageRecordId,
    String projectId,
    String responseText,
  ) {
    // TODO: Implementar parsing robusto da resposta JSON
    // Por enquanto, criar análise básica
    
    Map<String, dynamic> geminiData = {
      'rawResponse': responseText,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return AnalysisModel(
      id: '',
      imageRecordId: imageRecordId,
      projectId: projectId,
      analysisDate: DateTime.now(),
      status: 'completed',
      geminiResponse: geminiData,
      detectedElements: [],
      identifiedIssues: [],
      progressEstimate: null,
      comparisonWithBIM: null,
      deviations: null,
      createdAt: DateTime.now(),
    );
  }

  // Salvar análise no Firestore
  Future<String> _saveAnalysis(AnalysisModel analysis) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('analyses')
          .add(analysis.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao salvar análise: $e');
      rethrow;
    }
  }

  // Obter análise por ID
  Future<AnalysisModel?> getAnalysis(String analysisId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('analyses')
          .doc(analysisId)
          .get();
      
      if (doc.exists) {
        return AnalysisModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar análise: $e');
      return null;
    }
  }

  // Obter análises de um projeto
  Stream<List<AnalysisModel>> getProjectAnalyses(String projectId) {
    return _firestore
        .collection('analyses')
        .where('projectId', isEqualTo: projectId)
        .orderBy('analysisDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnalysisModel.fromFirestore(doc))
            .toList());
  }

  // Obter todas as análises
  Stream<List<AnalysisModel>> getAllAnalyses() {
    return _firestore
        .collection('analyses')
        .orderBy('analysisDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnalysisModel.fromFirestore(doc))
            .toList());
  }

  // Comparar duas imagens (progresso temporal)
  Future<Map<String, dynamic>?> compareImages(
    String imageUrl1,
    String imageUrl2,
  ) async {
    try {
      final httpClient = HttpClient();
      
      // Baixar primeira imagem
      final request1 = await httpClient.getUrl(Uri.parse(imageUrl1));
      final response1 = await request1.close();
      final List<int> bytesList1 = await response1.fold<List<int>>(
        [],
        (previous, element) => previous..addAll(element),
      );
      final Uint8List imageBytes1 = Uint8List.fromList(bytesList1);
      
      // Baixar segunda imagem
      final request2 = await httpClient.getUrl(Uri.parse(imageUrl2));
      final response2 = await request2.close();
      final List<int> bytesList2 = await response2.fold<List<int>>(
        [],
        (previous, element) => previous..addAll(element),
      );
      final Uint8List imageBytes2 = Uint8List.fromList(bytesList2);

      // Preparar prompt de comparação
      String prompt = '''
Compare estas duas imagens de canteiro de obras e identifique:
1. Mudanças visíveis entre as imagens
2. Progresso da construção
3. Novos elementos adicionados
4. Elementos removidos ou modificados
5. Estimativa de avanço percentual

Forneça a resposta em formato JSON estruturado.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes1),
          DataPart('image/jpeg', imageBytes2),
        ])
      ];

      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        return {
          'comparison': response.text,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao comparar imagens: $e');
      return null;
    }
  }
}

