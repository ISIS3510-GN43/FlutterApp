import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../usuario.dart';

/// Thrown when the backend accepted the photo URL (2xx) but didn't return
/// a full Usuario object. The caller can use [url] to update locally.
class PhotoUrlResult implements Exception {
  final String url;
  PhotoUrlResult(this.url);
}

class UsuarioRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Usuario> cambiarFoto(String userId, File imageFile) async {
    final ref = _storage.ref().child('profiles/$userId/foto.jpg');
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/usuarios/fotoPerfil/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'foto': downloadUrl}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return Usuario.fromJson(jsonDecode(response.body));
      } catch (_) {
        throw PhotoUrlResult(downloadUrl);
      }
    } else {
      throw Exception(
        'Backend error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
