import '../core/api_client.dart';

/// Stateless service handling all BlackBox-related API calls.
///
/// Covers journal entries, memory archive, and anonymous therapy sessions.
/// Each method returns the full response data as a [Map<String, dynamic>].
/// DioExceptions are left to propagate — the provider layer handles them.
class BlackBoxService {
  final ApiClient _api;

  BlackBoxService(this._api);

  /// POST /blackbox/entries
  /// Creates a new journal/emotional entry.
  /// Returns: created entry object
  Future<Map<String, dynamic>> createEntry({
    required String content,
    String contentType = 'text',
    bool isPrivate = false,
  }) async {
    final response = await _api.post(
      '/blackbox/entries',
      data: {
        'content': content,
        'content_type': contentType,
        'is_private': isPrivate,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /blackbox/entries
  /// Retrieves paginated entries with optional cursor.
  /// Returns: {entries, hasMore}
  Future<Map<String, dynamic>> getEntries({
    String? cursor,
    int limit = 30,
  }) async {
    final response = await _api.get(
      '/blackbox/entries',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// DELETE /blackbox/entries/:id
  /// Deletes an entry by ID.
  /// Returns: success confirmation
  Future<Map<String, dynamic>> deleteEntry(String id) async {
    final response = await _api.delete('/blackbox/entries/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /blackbox/sessions
  /// Creates a new anonymous therapy session or reconnects to an existing one.
  /// Returns: session object with reconnected flag
  Future<Map<String, dynamic>> createSession() async {
    final response = await _api.post('/blackbox/sessions');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /blackbox/sessions/active
  /// Retrieves sessions with status queued, accepted, or active.
  /// Returns: list of active sessions
  Future<Map<String, dynamic>> getActiveSessions() async {
    final response = await _api.get('/blackbox/sessions/active');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /blackbox/sessions/:id/cancel
  /// Cancels a queued session.
  /// Returns: updated session object
  Future<Map<String, dynamic>> cancelSession(String id) async {
    final response = await _api.patch('/blackbox/sessions/$id/cancel');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /blackbox/sessions/:id/end
  /// Ends an active session.
  /// Returns: updated session object
  Future<Map<String, dynamic>> endSession(String id) async {
    final response = await _api.patch('/blackbox/sessions/$id/end');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /blackbox/sessions/:id/join
  /// Joins a session (therapist action).
  /// Returns: updated session object
  Future<Map<String, dynamic>> joinSession(String id) async {
    final response = await _api.patch('/blackbox/sessions/$id/join');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /blackbox/sessions/:id
  /// Retrieves a specific session's current status and details.
  Future<Map<String, dynamic>> getSessionById(String id) async {
    final response = await _api.get('/blackbox/sessions/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /blackbox/therapist/queue
  /// Retrieves all queued student sessions awaiting an expert.
  Future<Map<String, dynamic>> getTherapistQueue() async {
    final response = await _api.get('/blackbox/therapist/queue');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /blackbox/therapist/sessions/:id/accept
  /// Accepts a queued session by providing a generated VideoSDK room ID.
  Future<Map<String, dynamic>> acceptSession(String id, String roomId) async {
    final response = await _api.patch(
      '/blackbox/therapist/sessions/$id/accept',
      data: {'room_id': roomId},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /blackbox/therapist/sessions/:id/join
  /// Marks the therapist as successfully joined the VideoSDK session.
  Future<Map<String, dynamic>> therapistJoinSession(String id) async {
    final response = await _api.patch('/blackbox/therapist/sessions/$id/join');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
