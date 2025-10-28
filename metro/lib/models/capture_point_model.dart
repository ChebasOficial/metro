import 'package:cloud_firestore/cloud_firestore.dart';

class CapturePointModel {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? referenceImage; // URL da imagem de referência
  final Map<String, dynamic>? bimReference; // Referência ao ponto no modelo BIM
  final DateTime createdAt;
  final DateTime updatedAt;

  CapturePointModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.referenceImage,
    this.bimReference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CapturePointModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CapturePointModel(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      referenceImage: data['referenceImage'],
      bimReference: data['bimReference'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'referenceImage': referenceImage,
      'bimReference': bimReference,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CapturePointModel copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? referenceImage,
    Map<String, dynamic>? bimReference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CapturePointModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      referenceImage: referenceImage ?? this.referenceImage,
      bimReference: bimReference ?? this.bimReference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

