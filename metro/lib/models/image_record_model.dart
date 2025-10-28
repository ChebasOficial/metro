import 'package:cloud_firestore/cloud_firestore.dart';

class ImageRecordModel {
  final String id;
  final String projectId;
  final String capturePointId;
  final String imageUrl;
  final String thumbnailUrl;
  final String? imageBase64; // Imagem em Base64
  final DateTime captureDate;
  final String capturedBy; // User ID
  final String capturedByName;
  final double? latitude;
  final double? longitude;
  final String? constructionPhase; // Fase da obra
  final Map<String, dynamic>? metadata; // Metadados adicionais
  final String analysisStatus; // 'pending', 'processing', 'completed', 'failed'
  final String? analysisId; // Referência para análise de IA
  final DateTime createdAt;
  final DateTime updatedAt;

  ImageRecordModel({
    required this.id,
    required this.projectId,
    required this.capturePointId,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.imageBase64,
    required this.captureDate,
    required this.capturedBy,
    required this.capturedByName,
    this.latitude,
    this.longitude,
    this.constructionPhase,
    this.metadata,
    required this.analysisStatus,
    this.analysisId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImageRecordModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ImageRecordModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      capturePointId: data['capturePointId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      imageBase64: data['imageBase64'],
      captureDate: (data['captureDate'] as Timestamp).toDate(),
      capturedBy: data['capturedBy'] ?? '',
      capturedByName: data['capturedByName'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      constructionPhase: data['constructionPhase'],
      metadata: data['metadata'],
      analysisStatus: data['analysisStatus'] ?? 'pending',
      analysisId: data['analysisId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'capturePointId': capturePointId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      'captureDate': Timestamp.fromDate(captureDate),
      'capturedBy': capturedBy,
      'capturedByName': capturedByName,
      'latitude': latitude,
      'longitude': longitude,
      'constructionPhase': constructionPhase,
      'metadata': metadata,
      'analysisStatus': analysisStatus,
      'analysisId': analysisId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ImageRecordModel copyWith({
    String? id,
    String? projectId,
    String? capturePointId,
    String? imageUrl,
    String? thumbnailUrl,
    String? imageBase64,
    DateTime? captureDate,
    String? capturedBy,
    String? capturedByName,
    double? latitude,
    double? longitude,
    String? constructionPhase,
    Map<String, dynamic>? metadata,
    String? analysisStatus,
    String? analysisId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ImageRecordModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      capturePointId: capturePointId ?? this.capturePointId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
      captureDate: captureDate ?? this.captureDate,
      capturedBy: capturedBy ?? this.capturedBy,
      capturedByName: capturedByName ?? this.capturedByName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      constructionPhase: constructionPhase ?? this.constructionPhase,
      metadata: metadata ?? this.metadata,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysisId: analysisId ?? this.analysisId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

