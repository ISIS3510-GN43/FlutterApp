import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/usuario.dart';

class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  Future<Usuario> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw Exception('No se pudo obtener el UID del usuario.');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/usuarios/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Usuario.fromJson(data);
      } else {
        throw Exception('No se pudo obtener el usuario desde el backend.');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  Future<Usuario> register(Usuario usuario) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/usuarios/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      throw Exception('No se pudo registrar el usuario.');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  String _mapFirebaseError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'Correo inválido.';
      case 'invalid-credential':
        return 'Credenciales inválidas.';
      default:
        return 'Error de autenticación.';
    }
  }
}