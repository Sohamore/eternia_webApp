import '../core/api_client.dart';

/// Stateless service handling all credits-related API calls.
///
/// Each method returns the full response data as a [Map<String, dynamic>].
/// DioExceptions are left to propagate — the provider layer handles them.
class CreditsService {
  final ApiClient _api;

  CreditsService(this._api);

  /// GET /credits/balance
  /// Returns: {balance}
  Future<Map<String, dynamic>> getBalance() async {
    final response = await _api.get('/credits/balance');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /credits/earn
  /// Returns: {success, earned, weekly_cap_reached, new_balance}
  Future<Map<String, dynamic>> earn({
    required int amount,
    String? notes,
    String? referenceId,
  }) async {
    final response = await _api.post('/credits/earn', data: {
      'amount': amount,
      if (notes != null) 'notes': notes,
      if (referenceId != null) 'reference_id': referenceId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /credits/spend
  /// Returns: {success, spent, new_balance}
  Future<Map<String, dynamic>> spend({
    required int amount,
    String? notes,
    String? referenceId,
  }) async {
    final response = await _api.post('/credits/spend', data: {
      'amount': amount,
      if (notes != null) 'notes': notes,
      if (referenceId != null) 'reference_id': referenceId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /credits/transactions?limit=50
  /// Returns: {transactions}
  Future<Map<String, dynamic>> getTransactions({int limit = 50}) async {
    final response = await _api.get(
      '/credits/transactions',
      queryParameters: {'limit': limit},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /credits/weekly-earn-total
  /// Returns: {total}
  Future<Map<String, dynamic>> getWeeklyEarnTotal() async {
    final response = await _api.get('/credits/weekly-earn-total');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /credits/purchase/create-order
  /// Returns: {order_id, amount}
  Future<Map<String, dynamic>> createOrder({required int credits}) async {
    final response = await _api.post('/credits/purchase/create-order', data: {
      'credits': credits,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /credits/purchase/verify-payment
  /// Returns: {success, new_balance}
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    final response =
        await _api.post('/credits/purchase/verify-payment', data: {
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': orderId,
      'razorpay_signature': signature,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
