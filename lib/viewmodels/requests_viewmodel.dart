import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../models/repositories/requests_repository.dart';

class RequestsViewModel extends ChangeNotifier {
  final RequestsRepository _repository;

  RequestsViewModel({RequestsRepository? repository})
      : _repository = repository ?? RequestsRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Usuario> _requests = [];
  Usuario? _searchedUser;
  bool _isSearching = false;
  bool _isSendingRequest = false;
  String _searchMessage = '';
  bool _isOffline = false;

  Usuario? get searchedUser => _searchedUser;
  bool get isSearching => _isSearching;
  bool get isSendingRequest => _isSendingRequest;
  String get searchMessage => _searchMessage;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Usuario> get requests => _requests;
  bool get hasRequests => _requests.isNotEmpty;
  bool get isOffline => _isOffline;

  Future<void> loadRequests(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _isOffline = false;
    notifyListeners();

    try {
      _requests = await _repository.getRequests(userId);
    } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
          _isOffline = true;
          if (_requests.isEmpty) {
            _errorMessage = 'No internet connection';
          }
        } else {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptRequest({
    required String currentUserId,
    required String senderUserId,
  }) async {
    try {
      await _repository.acceptRequest(
        currentUserId: currentUserId,
        senderUserId: senderUserId,
      );
      _repository.trackEvent("Accept request", currentUserId);
      await loadRequests(currentUserId);
      return true;
    } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
          _isOffline = true;
        } else {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        notifyListeners();
        return false;
    }
  }

  Future<bool> rejectRequest({
    required String currentUserId,
    required String senderUserId,
  }) async {
    try {
      await _repository.rejectRequest(
        currentUserId: currentUserId,
        senderUserId: senderUserId,
      );
      _repository.trackEvent("Reject request", currentUserId);
      await loadRequests(currentUserId);
      return true;
    } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
          _isOffline = true;
        } else {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        notifyListeners();
        return false;
    }
  }

  Future<void> searchUserByUsername(String username, String currentUserId) async {
    _isSearching = true;
    _searchMessage = '';
    _searchedUser = null;
    notifyListeners();

    try {
      final trimmedUsername = username.trim();

      if (trimmedUsername.isEmpty) {
        _searchMessage = 'Enter a username';
        return;
      }

      final user = await _repository.findUserByUsername(trimmedUsername);

      if (user == null) {
        _searchMessage = 'User not found';
        return;
      }

      if (user.id == currentUserId) {
        _searchMessage = 'You cannot send a request to yourself';
        return;
      }

      _searchedUser = user;
    } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
          _searchMessage = 'No internet connection';
        } else {
          _searchMessage = e.toString().replaceFirst('Exception: ', '');
        }
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> sendFriendRequest({
    required String targetUserId,
    required String senderUserId,
  }) async {
    _isSendingRequest = true;
    notifyListeners();

    try {
      await _repository.sendRequest(
        targetUserId: targetUserId,
        senderUserId: senderUserId,
      );
      _repository.trackEvent("Create request", senderUserId);
      return true;
    } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('socketexception') || msg.contains('timeout') || msg.contains('connection')) {
          _searchMessage = 'No internet connection';
        } else {
          _searchMessage = e.toString().replaceFirst('Exception: ', '');
        }
        notifyListeners();
        return false;
    } finally {
      _isSendingRequest = false;
      notifyListeners();
    }
  }

  void clearSearchState() {
    _searchedUser = null;
    _searchMessage = '';
    _isSearching = false;
    _isSendingRequest = false;
    notifyListeners();
  }
}