import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/videosdk_service.dart';
import '../core/api_error.dart';
import '../core/api_client.dart';

class VideoSDKProvider with ChangeNotifier {
  final VideoSDKService _service;
  bool _isLoading = false;
  String? _error;
  String? _token;
  String? _roomId;

  VideoSDKProvider(this._service);

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get roomId => _roomId;

  Future<void> fetchToken() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.getToken();
      _token = res['token'];
    } catch (e) {
      if (e is DioException) {
        _error = ApiClient.classifyError(e).message;
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> startNewRoom() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.createRoom();
      _token = res['token'];
      _roomId = res['roomId'];
      return _roomId;
    } catch (e) {
      if (e is DioException) {
        _error = ApiClient.classifyError(e).message;
      } else {
        _error = e.toString();
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

