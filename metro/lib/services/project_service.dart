import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar novo projeto
  Future<String> createProject(ProjectModel project) async {
    try {
      DocumentReference docRef = await _firestore.collection('projects').add(
        project.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar projeto: $e');
      rethrow;
    }
  }

  // Atualizar projeto
  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('projects').doc(projectId).update(updates);
    } catch (e) {
      debugPrint('Erro ao atualizar projeto: $e');
      rethrow;
    }
  }

  // Deletar projeto
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar projeto: $e');
      rethrow;
    }
  }

  // Obter projeto por ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar projeto: $e');
      return null;
    }
  }

  // Obter todos os projetos
  Stream<List<ProjectModel>> getAllProjects() {
    return _firestore
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Obter projetos do usuário atual
  Stream<List<ProjectModel>> getUserProjects() {
    // Importar Firebase Auth para obter usuário atual
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Obter projetos por status
  Stream<List<ProjectModel>> getProjectsByStatus(String status) {
    return _firestore
        .collection('projects')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Obter projetos atribuídos a um engenheiro
  Stream<List<ProjectModel>> getProjectsByEngineer(String engineerId) {
    return _firestore
        .collection('projects')
        .where('responsibleEngineers', arrayContains: engineerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromFirestore(doc))
            .toList());
  }

  // Adicionar engenheiro responsável
  Future<void> addResponsibleEngineer(String projectId, String engineerId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'responsibleEngineers': FieldValue.arrayUnion([engineerId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao adicionar engenheiro: $e');
      rethrow;
    }
  }

  // Remover engenheiro responsável
  Future<void> removeResponsibleEngineer(String projectId, String engineerId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'responsibleEngineers': FieldValue.arrayRemove([engineerId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao remover engenheiro: $e');
      rethrow;
    }
  }

  // Atualizar status do projeto
  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar status: $e');
      rethrow;
    }
  }

  // Buscar projetos por nome ou localização
  Future<List<ProjectModel>> searchProjects(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('projects')
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar projetos: $e');
      return [];
    }
  }
}

