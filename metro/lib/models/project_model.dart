import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime? expectedEndDate;
  final String status; // 'em_andamento', 'pausado', 'concluido'
  final List<String> responsibleEngineers;
  final Map<String, dynamic>? bimData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId; // ID do usuário que criou o projeto
  final List<String> members; // IDs dos usuários membros do projeto

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    this.expectedEndDate,
    required this.status,
    required this.responsibleEngineers,
    this.bimData,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.members = const [],
  });

  // Converter de Firestore para Model
  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      expectedEndDate: data['expectedEndDate'] != null
          ? (data['expectedEndDate'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'em_andamento',
      responsibleEngineers: List<String>.from(data['responsibleEngineers'] ?? []),
      bimData: data['bimData'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  // Converter de Model para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'expectedEndDate': expectedEndDate != null
          ? Timestamp.fromDate(expectedEndDate!)
          : null,
      'status': status,
      'responsibleEngineers': responsibleEngineers,
      'bimData': bimData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
      'members': members,
    };
  }

  // Criar cópia com modificações
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? expectedEndDate,
    String? status,
    List<String>? responsibleEngineers,
    Map<String, dynamic>? bimData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<String>? members,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      status: status ?? this.status,
      responsibleEngineers: responsibleEngineers ?? this.responsibleEngineers,
      bimData: bimData ?? this.bimData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      members: members ?? this.members,
    );
  }
}

