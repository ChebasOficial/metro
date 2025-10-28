import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/image_record_model.dart';

class ImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Capturar imagem da câmera
  Future<XFile?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Erro ao capturar imagem: $e');
      return null;
    }
  }

  // Selecionar imagem da galeria
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      return null;
    }
  }

  // Converter imagem para Base64 e salvar no Firestore
  Future<String?> saveImageToFirestore(
    File imageFile,
    String projectId,
    String capturePointId,
  ) async {
    try {
      // Ler bytes da imagem
      final bytes = await imageFile.readAsBytes();
      
      // Converter para Base64
      final base64Image = base64Encode(bytes);
      
      // Criar timestamp único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageId = 'img_${projectId}_${capturePointId}_$timestamp';
      
      // Salvar no Firestore
      await _firestore.collection('images').doc(imageId).set({
        'imageData': base64Image,
        'projectId': projectId,
        'capturePointId': capturePointId,
        'timestamp': Timestamp.now(),
        'size': bytes.length,
      });
      
      debugPrint('Imagem salva no Firestore: $imageId');
      return imageId;
    } catch (e) {
      debugPrint('Erro ao salvar imagem: $e');
      return null;
    }
  }

  // Criar registro de imagem
  Future<String?> createImageRecord(
    String projectId,
    String capturePointId,
    String imageId,
    String userId, {
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      ImageRecordModel record = ImageRecordModel(
        id: '',
        projectId: projectId,
        capturePointId: capturePointId,
        imageUrl: imageId, // URL da imagem
        thumbnailUrl: imageId, // Mesma URL por enquanto
        capturedBy: userId,
        capturedByName: 'Usuário', // TODO: Buscar nome real do usuário
        captureDate: DateTime.now(),
        analysisStatus: 'pending',
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection('image_records')
          .add(record.toFirestore());

      debugPrint('Registro de imagem criado: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar registro de imagem: $e');
      return null;
    }
  }

  // Obter imagem do Firestore como Base64
  Future<String?> getImageBase64(String imageId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('images')
          .doc(imageId)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['imageData'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar imagem: $e');
      return null;
    }
  }

  // Obter registro de imagem
  Future<ImageRecordModel?> getImageRecord(String recordId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('image_records')
          .doc(recordId)
          .get();

      if (doc.exists) {
        return ImageRecordModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar registro de imagem: $e');
      return null;
    }
  }

  // Obter registros de imagem de um ponto de captura
  Stream<List<ImageRecordModel>> getCapturePointImages(String capturePointId) {
    return _firestore
        .collection('image_records')
        .where('capturePointId', isEqualTo: capturePointId)
        .orderBy('captureDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ImageRecordModel.fromFirestore(doc))
            .toList());
  }

  // Obter todas as imagens de um projeto
  Stream<List<ImageRecordModel>> getProjectImages(String projectId) {
    return _firestore
        .collection('image_records')
        .where('projectId', isEqualTo: projectId)
        .orderBy('captureDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ImageRecordModel.fromFirestore(doc))
            .toList());
  }

  // Atualizar status de análise
  Future<void> updateAnalysisStatus(
    String recordId,
    String status, {
    String? analysisId,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'analysisStatus': status,
        'updatedAt': Timestamp.now(),
      };

      if (analysisId != null) {
        updateData['analysisId'] = analysisId;
      }

      await _firestore
          .collection('image_records')
          .doc(recordId)
          .update(updateData);

      debugPrint('Status de análise atualizado: $recordId -> $status');
    } catch (e) {
      debugPrint('Erro ao atualizar status de análise: $e');
    }
  }

  // Deletar imagem e seu registro
  Future<bool> deleteImage(String recordId, String imageId) async {
    try {
      // Deletar imagem do Firestore
      await _firestore.collection('images').doc(imageId).delete();
      
      // Deletar registro
      await _firestore.collection('image_records').doc(recordId).delete();
      
      debugPrint('Imagem deletada: $imageId');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar imagem: $e');
      return false;
    }
  }

  // Obter estatísticas de imagens de um projeto
  Future<Map<String, int>> getProjectImageStats(String projectId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('image_records')
          .where('projectId', isEqualTo: projectId)
          .get();

      int total = snapshot.docs.length;
      int pending = 0;
      int processing = 0;
      int completed = 0;
      int failed = 0;

      for (var doc in snapshot.docs) {
        String status = doc.get('analysisStatus') ?? 'pending';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'processing':
            processing++;
            break;
          case 'completed':
            completed++;
            break;
          case 'failed':
            failed++;
            break;
        }
      }

      return {
        'total': total,
        'pending': pending,
        'processing': processing,
        'completed': completed,
        'failed': failed,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas: $e');
      return {
        'total': 0,
        'pending': 0,
        'processing': 0,
        'completed': 0,
        'failed': 0,
      };
    }
  }
}

