import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obter dados do usuário do Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  // Login com email e senha
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Atualizar último login
      await updateLastLogin(result.user!.uid);
      
      return result;
    } catch (e) {
      debugPrint('Erro no login: $e');
      rethrow;
    }
  }

  // Registro com email e senha
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criar documento do usuário no Firestore
      await _createUserDocument(
        result.user!.uid,
        email,
        name,
        phone,
      );

      return result;
    } catch (e) {
      debugPrint('Erro no registro: $e');
      rethrow;
    }
  }

  // Criar documento do usuário
  Future<void> _createUserDocument(
    String userId,
    String email,
    String name,
    String? phone,
  ) async {
    try {
      UserModel newUser = UserModel(
        id: userId,
        email: email,
        name: name,
        phone: phone,
        role: 'visualizador', // Role padrão
        assignedProjects: [],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toFirestore());
    } catch (e) {
      debugPrint('Erro ao criar documento do usuário: $e');
      rethrow;
    }
  }

  // Atualizar último login
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar último login: $e');
    }
  }

  // Atualizar perfil do usuário
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.now(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erro no logout: $e');
      rethrow;
    }
  }

  // Reset de senha
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Erro no reset de senha: $e');
      return false;
    }
  }

  // Verificar se o usuário está logado
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Verificar se email já existe
  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar email: $e');
      return false;
    }
  }
}

