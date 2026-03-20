import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  Usuario? _usuarioActual;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Usuario? get usuarioActual => _usuarioActual;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _usuarioActual = await _authRepository.login(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _usuarioActual = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}