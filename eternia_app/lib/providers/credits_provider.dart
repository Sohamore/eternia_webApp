import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/credits_service.dart';

class CreditsProvider extends ChangeNotifier {
  final CreditsService _service;

  bool _isLoading = false;
  String? _error;
  int? _balance;
  int? _weeklyEarnTotal;
  List<Map<String, dynamic>>? _transactions;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get balance => _balance;
  int? get weeklyEarnTotal => _weeklyEarnTotal;
  List<Map<String, dynamic>>? get transactions => _transactions;

  CreditsProvider(this._service);

  Future<void> fetchBalance({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getBalance();
      _balance = (data['balance'] as num?)?.toInt() ?? 0;
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeeklyTotal() async {
    try {
      final data = await _service.getWeeklyEarnTotal();
      _weeklyEarnTotal = (data['total'] as num?)?.toInt() ?? 0;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getTransactions();
      _transactions = List<Map<String, dynamic>>.from(data['transactions'] as List? ?? []);
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> earn({required int amount, String? notes, String? referenceId}) async {
    _error = null;
    try {
      await _service.earn(amount: amount, notes: notes, referenceId: referenceId);
      await fetchBalance(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> spend({required int amount, String? notes, String? referenceId}) async {
    _error = null;
    try {
      await _service.spend(amount: amount, notes: notes, referenceId: referenceId);
      await fetchBalance(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
