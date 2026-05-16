import '../core/api_client.dart';

/// Stateless service handling all peer-support session API calls.
///
/// Each method returns the full response data as a [Map<String, dynamic>].
/// DioExceptions are left to propagate — the provider layer handles them.
class PeersService {
  final ApiClient _api;

  PeersService(this._api);

  /// GET /peers/interns
  /// Returns: list of available interns for peer sessions.
  Future<Map<String, dynamic>> getInterns() async {
    final response = await _api.get('/peers/interns');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /peers/sessions
  /// Creates a new peer session request with the given intern.
  Future<Map<String, dynamic>> createSession(String internId) async {
    final response = await _api.post('/peers/sessions', data: {
      'intern_id': internId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /peers/sessions/:id/accept
  /// Accepts a pending peer session.
  Future<Map<String, dynamic>> acceptSession(String id) async {
    final response = await _api.patch('/peers/sessions/$id/accept');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /peers/sessions/:id/decline
  /// Declines a pending peer session.
  Future<Map<String, dynamic>> declineSession(String id) async {
    final response = await _api.patch('/peers/sessions/$id/decline');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /peers/sessions/:id/end
  /// Ends an active peer session.
  Future<Map<String, dynamic>> endSession(String id) async {
    final response = await _api.patch('/peers/sessions/$id/end');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /peers/sessions/:id/flag
  /// Flags a session for escalation with optional note and justification.
  Future<Map<String, dynamic>> flagSession(
    String id, {
    String? escalationNote,
    String? justification,
  }) async {
    final response = await _api.patch('/peers/sessions/$id/flag', data: {
      if (escalationNote != null) 'escalation_note': escalationNote,
      if (justification != null) 'justification': justification,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /peers/sessions
  /// Returns: list of the user's peer sessions.
  Future<Map<String, dynamic>> getSessions() async {
    final response = await _api.get('/peers/sessions');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /peers/sessions/:sessionId/messages
  /// Returns: paginated messages for a session.
  Future<Map<String, dynamic>> getMessages(
    String sessionId, {
    String? cursor,
    int? limit,
  }) async {
    final response = await _api.get(
      '/peers/sessions/$sessionId/messages',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /peers/sessions/:sessionId/messages
  /// Sends a message in a peer session.
  Future<Map<String, dynamic>> sendMessage(
    String sessionId,
    String content,
  ) async {
    final response = await _api.post(
      '/peers/sessions/$sessionId/messages',
      data: {'content': content},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /peers/sessions/:sessionId/start-call
  /// Initiates a video call for the session.
  Future<Map<String, dynamic>> startCall(String sessionId) async {
    final response =
        await _api.patch('/peers/sessions/$sessionId/start-call');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
