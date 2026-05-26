import '../core/api_client.dart';

/// Stateless service handling all appointments-related API calls.
///
/// Each method returns the full response data as a [Map<String, dynamic>].
/// DioExceptions are left to propagate — the provider layer handles them.
class AppointmentsService {
  final ApiClient _api;

  AppointmentsService(this._api);

  /// GET /appointments/experts?institution_id=...
  /// Returns: list of active experts
  Future<Map<String, dynamic>> getExperts({String? institutionId}) async {
    final response = await _api.get(
      '/appointments/experts',
      queryParameters: {
        if (institutionId != null) 'institution_id': institutionId,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /appointments/slots?expert_id=...
  /// Returns: list of available slots for the given expert
  Future<Map<String, dynamic>> getSlots(String expertId) async {
    final response = await _api.get(
      '/appointments/slots',
      queryParameters: {'expert_id': expertId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /appointments/
  /// Returns: created appointment object
  Future<Map<String, dynamic>> book({
    required String expertId,
    String? slotId,
    required String slotTime,
    String? sessionType,
    int? creditsCharged,
    String? roomId,
  }) async {
    final response = await _api.post('/appointments/', data: {
      'expert_id': expertId,
      if (slotId != null) 'slot_id': slotId,
      'slot_time': slotTime,
      if (sessionType != null) 'session_type': sessionType,
      if (creditsCharged != null) 'credits_charged': creditsCharged,
      if (roomId != null) 'room_id': roomId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /appointments/:id/cancel
  /// Returns: updated appointment with cancelled status
  Future<Map<String, dynamic>> cancel(String id) async {
    final response = await _api.patch('/appointments/$id/cancel');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /appointments/:id/complete
  /// Returns: success boolean
  Future<Map<String, dynamic>> complete(String id, [String? notes]) async {
    final response = await _api.patch(
      '/appointments/$id/complete',
      data: {if (notes != null) 'notes': notes},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /appointments/:id/reschedule
  /// Returns: updated appointment with new slot time
  Future<Map<String, dynamic>> reschedule(
    String id, {
    required String slotId,
    required String reason,
  }) async {
    final response = await _api.patch('/appointments/$id/reschedule', data: {
      'slot_id': slotId,
      'reschedule_reason': reason,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /appointments/
  /// Returns: list of past and upcoming appointments
  Future<Map<String, dynamic>> getHistory() async {
    final response = await _api.get('/appointments/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /appointments/:id/messages
  /// Returns: list of messages for this appointment chat
  Future<Map<String, dynamic>> getMessages(String appointmentId) async {
    final response = await _api.get('/appointments/$appointmentId/messages');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /appointments/:id/messages
  /// Sends a message in this appointment chat
  Future<Map<String, dynamic>> sendMessage(String appointmentId, String content) async {
    final response = await _api.post(
      '/appointments/$appointmentId/messages',
      data: {'content': content},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
