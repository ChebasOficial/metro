import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/image_record_model.dart';

class ImageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  // Upload de imagem para Firebase Storage
  Future<Map<String, String>?> uploadImage(
    File imageFile,
    String projectId,
    String capturePointId,
  ) async {
    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'projects/$projectId/$capturePointId/$timestamp.jpg';
      String thumbnailName = 'projects/$projectId/$capturePointId/${timestamp}_thumb.jpg';

      // Upload imagem original
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // TODO: Gerar e fazer upload da thumbnail
      // Por enquanto, usar a mesma URL
      String thumbnailUrl = imageUrl;

      return {
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
      };
    } catch (e) {
      debugPrint('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  // Criar registro de imagem
  Future<String> createImageRecord(ImageRecordModel imageRecord) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('image_records')
          .add(imageRecord.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao criar registro de imagem: $e');
      rethrow;
    }
  }

  // Atualizar registro de imagem
  Future<void> updateImageRecord(
    String imageRecordId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore
          .collection('image_records')
          .doc(imageRecordId)
          .update(updates);
    } catch (e) {
      debugPrint('Erro ao atualizar registro de imagem: $e');
      rethrow;
    }
  }

  // Deletar registro de imagem
  Future<void> deleteImageRecord(String imageRecordId) async {
    try {
      // Buscar o registro para obter as URLs das imagens
      DocumentSnapshot doc = await _firestore
          .collection('image_records')
          .doc(imageRecordId)
          .get();
      
      if (doc.exists) {
        ImageRecordModel record = ImageRecordModel.fromFirestore(doc);
        
        // Deletar imagens do Storage
        try {
          await _storage.refFromURL(record.imageUrl).delete();
          if (record.thumbnailUrl != record.imageUrl) {
            await _storage.refFromURL(record.thumbnailUrl).delete();
          }
        } catch (e) {
          debugPrint('Erro ao deletar imagens do storage: $e');
        }
        
        // Deletar documento
        await _firestore.collection('image_records').doc(imageRecordId).delete();
      }
    } catch (e) {
      debugPrint('Erro ao deletar registro de imagem: $e');
      rethrow;
    }
  }

  // Obter imagens de um projeto
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

  // Obter imagens de um ponto de captura
  Stream<List<ImageRecordModel>> getCapturePointImages(
    String projectId,
    String capturePointId,
  ) {
    return _firestore
        .collection('image_records')
        .where('projectId', isEqualTo: projectId)
        .where('capturePointId', isEqualTo: capturePointId)
        .orderBy('captureDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ImageRecordModel.fromFirestore(doc))
            .toList());
  }

  // Obter imagens por período
  Stream<List<ImageRecordModel>> getImagesByDateRange(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('image_records')
        .where('projectId', isEqualTo: projectId)
        .where('captureDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('captureDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('captureDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ImageRecordModel.fromFirestore(doc))
            .toList());
  }

  // Obter imagem por ID
  Future<ImageRecordModel?> getImageRecord(String imageRecordId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('image_records')
          .doc(imageRecordId)
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

  // Obter estatísticas de imagens do projeto
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
        ImageRecordModel record = ImageRecordModel.fromFirestore(doc);
        switch (record.analysisStatus) {
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
      debugPrint('Erro ao buscar estatísticas: $e');
      return {};
    }
  }
}

