import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar novo alerta
  Future<String> createAlert(AlertModel alert) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('alerts')
          .add(alert.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar alerta: $e');
      rethrow;
    }
  }

  // Atualizar alerta
  Future<void> updateAlert(
    String alertId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('alerts').doc(alertId).update(updates);
    } catch (e) {
      debugPrint('Erro ao atualizar alerta: $e');
      rethrow;
    }
  }

  // Deletar alerta
  Future<void> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).delete();
    } catch (e) {
      debugPrint('Erro ao deletar alerta: $e');
      rethrow;
    }
  }

  // Obter alerta por ID
  Future<AlertModel?> getAlert(String alertId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('alerts')
          .doc(alertId)
          .get();
      
      if (doc.exists) {
        return AlertModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar alerta: $e');
      return null;
    }
  }

  // Obter alertas de um projeto
  Stream<List<AlertModel>> getProjectAlerts(String projectId) {
    return _firestore
        .collection('alerts')
        .where('projectId', isEqualTo: projectId)
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Obter todos os alertas
  Stream<List<AlertModel>> getAllAlerts() {
    return _firestore
        .collection('alerts')
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Obter alertas com filtros opcionais
  Stream<List<AlertModel>> getAlerts({String? severity, String? status}) {
    Query query = _firestore.collection('alerts');
    
    if (severity != null) {
      query = query.where('severity', isEqualTo: severity);
    }
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    return query
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Obter alertas por status
  Stream<List<AlertModel>> getAlertsByStatus(
    String projectId,
    String status,
  ) {
    return _firestore
        .collection('alerts')
        .where('projectId', isEqualTo: projectId)
        .where('status', isEqualTo: status)
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Obter alertas por severidade
  Stream<List<AlertModel>> getAlertsBySeverity(
    String projectId,
    String severity,
  ) {
    return _firestore
        .collection('alerts')
        .where('projectId', isEqualTo: projectId)
        .where('severity', isEqualTo: severity)
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Obter alertas atribuídos a um usuário
  Stream<List<AlertModel>> getAssignedAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .where('assignedTo', isEqualTo: userId)
        .where('status', whereIn: ['aberto', 'em_analise'])
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromFirestore(doc))
            .toList());
  }

  // Atribuir alerta a um usuário
  Future<void> assignAlert(String alertId, String userId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'assignedTo': userId,
        'status': 'em_analise',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao atribuir alerta: $e');
      rethrow;
    }
  }

  // Resolver alerta
  Future<void> resolveAlert(
    String alertId, {
    String? resolution,
  }) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'status': 'resolved',
        'resolvedAt': Timestamp.now(),
        if (resolution != null) 'resolution': resolution,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao resolver alerta: $e');
      rethrow;
    }
  }

  // Ignorar alerta
  Future<void> dismissAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'status': 'ignorado',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao ignorar alerta: $e');
      rethrow;
    }
  }

  // Reabrir alerta
  Future<void> reopenAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'status': 'aberto',
        'resolvedAt': null,
        'resolution': null,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao reabrir alerta: $e');
      rethrow;
    }
  }

  // Obter estatísticas de alertas do projeto
  Future<Map<String, dynamic>> getProjectAlertStats(String projectId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('alerts')
          .where('projectId', isEqualTo: projectId)
          .get();

      int total = snapshot.docs.length;
      int abertos = 0;
      int emAnalise = 0;
      int resolvidos = 0;
      int ignorados = 0;
      
      Map<String, int> bySeverity = {
        'baixa': 0,
        'media': 0,
        'alta': 0,
        'critica': 0,
      };
      
      Map<String, int> byType = {};

      for (var doc in snapshot.docs) {
        AlertModel alert = AlertModel.fromFirestore(doc);
        
        // Contar por status
        switch (alert.status) {
          case 'aberto':
            abertos++;
            break;
          case 'em_analise':
            emAnalise++;
            break;
          case 'resolvido':
            resolvidos++;
            break;
          case 'ignorado':
            ignorados++;
            break;
        }
        
        // Contar por severidade
        bySeverity[alert.severity] = (bySeverity[alert.severity] ?? 0) + 1;
        
        // Contar por tipo
        byType[alert.type] = (byType[alert.type] ?? 0) + 1;
      }

      return {
        'total': total,
        'abertos': abertos,
        'emAnalise': emAnalise,
        'resolvidos': resolvidos,
        'ignorados': ignorados,
        'bySeverity': bySeverity,
        'byType': byType,
      };
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas de alertas: $e');
      return {};
    }
  }

  // Criar alerta automático a partir de análise
  Future<String?> createAlertFromAnalysis(
    String projectId,
    String imageRecordId,
    String analysisId,
    List<String> issues,
  ) async {
    if (issues.isEmpty) return null;

    try {
      AlertModel alert = AlertModel(
        id: '',
        projectId: projectId,
        imageRecordId: imageRecordId,
        analysisId: analysisId,
        type: 'desvio',
        severity: _determineSeverity(issues),
        title: 'Problemas detectados automaticamente',
        description: issues.join('\n'),
        status: 'aberto',
        detectedAt: DateTime.now(),
        affectedAreas: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createAlert(alert);
    } catch (e) {
      debugPrint('Erro ao criar alerta automático: $e');
      return null;
    }
  }

  // Determinar severidade baseado nos problemas
  String _determineSeverity(List<String> issues) {
    // Lógica simples - pode ser expandida
    if (issues.any((issue) => 
        issue.toLowerCase().contains('estrutural') ||
        issue.toLowerCase().contains('segurança') ||
        issue.toLowerCase().contains('crítico'))) {
      return 'critica';
    } else if (issues.length > 3) {
      return 'alta';
    } else if (issues.length > 1) {
      return 'media';
    }
    return 'baixa';
  }
}

