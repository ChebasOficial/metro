import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String id;
  final String projectId;
  final String? imageRecordId;
  final String? analysisId;
  final String type; // 'desvio', 'atraso', 'seguranca', 'qualidade'
  final String severity; // 'baixa', 'media', 'alta', 'critica'
  final String title;
  final String description;
  final String status; // 'aberto', 'em_analise', 'resolvido', 'ignorado'
  final String? assignedTo; // User ID do responsável
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolution; // Descrição da resolução
  final List<String> affectedAreas;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertModel({
    required this.id,
    required this.projectId,
    this.imageRecordId,
    this.analysisId,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.status,
    this.assignedTo,
    required this.detectedAt,
    this.resolvedAt,
    this.resolution,
    required this.affectedAreas,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      imageRecordId: data['imageRecordId'],
      analysisId: data['analysisId'],
      type: data['type'] ?? 'desvio',
      severity: data['severity'] ?? 'media',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'aberto',
      assignedTo: data['assignedTo'],
      detectedAt: (data['detectedAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      resolution: data['resolution'],
      affectedAreas: List<String>.from(data['affectedAreas'] ?? []),
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'imageRecordId': imageRecordId,
      'analysisId': analysisId,
      'type': type,
      'severity': severity,
      'title': title,
      'description': description,
      'status': status,
      'assignedTo': assignedTo,
      'detectedAt': Timestamp.fromDate(detectedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolution': resolution,
      'affectedAreas': affectedAreas,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AlertModel copyWith({
    String? id,
    String? projectId,
    String? imageRecordId,
    String? analysisId,
    String? type,
    String? severity,
    String? title,
    String? description,
    String? status,
    String? assignedTo,
    DateTime? detectedAt,
    DateTime? resolvedAt,
    String? resolution,
    List<String>? affectedAreas,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      imageRecordId: imageRecordId ?? this.imageRecordId,
      analysisId: analysisId ?? this.analysisId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      affectedAreas: affectedAreas ?? this.affectedAreas,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

