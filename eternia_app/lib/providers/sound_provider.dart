import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/sound_service.dart';

class SoundProvider extends ChangeNotifier {
  final SoundService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _tracks;
  List<Map<String, dynamic>>? _filteredTracks;
  String? _selectedCategory;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get tracks => _filteredTracks ?? _tracks;
  String? get selectedCategory => _selectedCategory;

  SoundProvider(this._service);

  Future<void> fetchTracks({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      _tracks = await _service.getTracks();
      _lastFetched = DateTime.now();
      if (_selectedCategory != null) {
        _filteredTracks = _service.filterByCategory(_tracks!, _selectedCategory!);
      }
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    if (category == null || _tracks == null) {
      _filteredTracks = null;
    } else {
      _filteredTracks = _service.filterByCategory(_tracks!, category);
    }
    notifyListeners();
  }
}
