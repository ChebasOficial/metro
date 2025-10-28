import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisModel {
  final String id;
  final String imageRecordId;
  final String projectId;
  final DateTime analysisDate;
  final String status; // 'completed', 'failed'
  final Map<String, dynamic> geminiResponse; // Resposta completa da Gemini AI
  final List<DetectedElement> detectedElements;
  final List<String> identifiedIssues;
  final double? progressEstimate; // Estimativa de progresso (0-100)
  final String? comparisonWithBIM; // Resultado da comparação com BIM
  final Map<String, dynamic>? deviations; // Desvios identificados
  final DateTime createdAt;

  AnalysisModel({
    required this.id,
    required this.imageRecordId,
    required this.projectId,
    required this.analysisDate,
    required this.status,
    required this.geminiResponse,
    required this.detectedElements,
    required this.identifiedIssues,
    this.progressEstimate,
    this.comparisonWithBIM,
    this.deviations,
    required this.createdAt,
  });

  factory AnalysisModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AnalysisModel(
      id: doc.id,
      imageRecordId: data['imageRecordId'] ?? '',
      projectId: data['projectId'] ?? '',
      analysisDate: (data['analysisDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'completed',
      geminiResponse: data['geminiResponse'] ?? {},
      detectedElements: (data['detectedElements'] as List<dynamic>?)
              ?.map((e) => DetectedElement.fromMap(e))
              .toList() ??
          [],
      identifiedIssues: List<String>.from(data['identifiedIssues'] ?? []),
      progressEstimate: data['progressEstimate']?.toDouble(),
      comparisonWithBIM: data['comparisonWithBIM'],
      deviations: data['deviations'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageRecordId': imageRecordId,
      'projectId': projectId,
      'analysisDate': Timestamp.fromDate(analysisDate),
      'status': status,
      'geminiResponse': geminiResponse,
      'detectedElements': detectedElements.map((e) => e.toMap()).toList(),
      'identifiedIssues': identifiedIssues,
      'progressEstimate': progressEstimate,
      'comparisonWithBIM': comparisonWithBIM,
      'deviations': deviations,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class DetectedElement {
  final String type; // 'pilar', 'viga', 'laje', etc.
  final String description;
  final double confidence;
  final Map<String, dynamic>? boundingBox;

  DetectedElement({
    required this.type,
    required this.description,
    required this.confidence,
    this.boundingBox,
  });

  factory DetectedElement.fromMap(Map<String, dynamic> map) {
    return DetectedElement(
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      boundingBox: map['boundingBox'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'confidence': confidence,
      'boundingBox': boundingBox,
    };
  }
}

