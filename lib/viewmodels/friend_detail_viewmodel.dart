import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/repositories/friend_detail_repository.dart';

enum SendLocationState { idle, loading, success, noConnection, error }

class FriendDetailViewModel extends ChangeNotifier {
  final FriendDetailRepository _repository;

  FriendDetailViewModel({FriendDetailRepository? repository})
      : _repository = repository ?? FriendDetailRepository();

  SendLocationState _sendState = SendLocationState.idle;
  String _errorMessage = '';

  SendLocationState get sendState => _sendState;
  String get errorMessage => _errorMessage;
  bool get isLoading => _sendState == SendLocationState.loading;

  Future<void> sendLocation({
    required String userId,
    required String friendGmail,
    required String friendUsername,
  }) async {
    _sendState = SendLocationState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final currentUsername = await _repository.getCurrentUsername(userId);
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final mapsLink =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';


      final response = await http.post(
        Uri.parse('https://automation.luminotest.com/webhook/email-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': friendGmail,
          'name': friendUsername,
          'from': currentUsername,
          'mapsLink': mapsLink,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _sendState = SendLocationState.success;
      } else {
        throw Exception('Failed to send email. Try again.');
      }
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socketexception') ||
          msg.contains('timeout') ||
          msg.contains('connection')) {
        _sendState = SendLocationState.noConnection;
      } else {
        _sendState = SendLocationState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      notifyListeners();
    }
  }

  void resetState() {
    _sendState = SendLocationState.idle;
    _errorMessage = '';
    notifyListeners();
  }
}