import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import '../core/env_config.dart';
import '../core/token_storage.dart';

class SocketService {
  io.Socket? _socket;
  final TokenStorage _tokenStorage;
  
  // Streams for incoming events
  final _connectionStateController = StreamController<bool>.broadcast();
  final _incomingRequestController = StreamController<Map<String, dynamic>>.broadcast();
  final _sessionStartedController = StreamController<Map<String, dynamic>>.broadcast();
  final _requestCancelledController = StreamController<String>.broadcast();
  final _requestExpiredController = StreamController<String>.broadcast();
  final _sessionEndedController = StreamController<String>.broadcast();
  final _matchFailedController = StreamController<String>.broadcast();
  final _sessionRestoredController = StreamController<Map<String, dynamic>?>.broadcast();
  final _availabilityChangeController = StreamController<Map<String, dynamic>>.broadcast();

  SocketService(this._tokenStorage);

  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get incomingRequest => _incomingRequestController.stream;
  Stream<Map<String, dynamic>> get sessionStarted => _sessionStartedController.stream;
  Stream<String> get requestCancelled => _requestCancelledController.stream;
  Stream<String> get requestExpired => _requestExpiredController.stream;
  Stream<String> get sessionEnded => _sessionEndedController.stream;
  Stream<String> get matchFailed => _matchFailedController.stream;
  Stream<Map<String, dynamic>?> get sessionRestored => _sessionRestoredController.stream;
  Stream<Map<String, dynamic>> get availabilityChange => _availabilityChangeController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null) {
      debugPrint('[SocketService] Cannot connect without token');
      return;
    }

    final baseUrl = EnvConfig.baseUrl.replaceAll('/api', '');

    _socket = io.io(baseUrl, io.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setAuth({'token': token})
      .build()
    );

    _socket!.onConnect((_) {
      debugPrint('[SocketService] Connected to Socket.IO server');
      _connectionStateController.add(true);
      _socket!.emit('reconnect-user');
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SocketService] Disconnected from Socket.IO server');
      _connectionStateController.add(false);
    });

    _socket!.onConnectError((err) => debugPrint('[SocketService] Connect Error: $err'));

    // Matchmaking events
    _socket!.on('request-created', (data) {
      _incomingRequestController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('session-started', (data) {
      _sessionStartedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('request-cancelled', (data) {
      if (data != null && data['requestId'] != null) {
        _requestCancelledController.add(data['requestId'].toString());
      }
    });

    _socket!.on('request-expired', (data) {
      if (data != null && data['message'] != null) {
        _requestExpiredController.add(data['message'].toString());
      }
    });

    _socket!.on('session-ended', (data) {
      if (data != null && data['sessionId'] != null) {
        _sessionEndedController.add(data['sessionId'].toString());
      }
    });

    _socket!.on('match-failed', (data) {
      if (data != null && data['reason'] != null) {
        _matchFailedController.add(data['reason'].toString());
      }
    });

    _socket!.on('session-restored', (data) {
      if (data != null) {
        _sessionRestoredController.add(Map<String, dynamic>.from(data));
      } else {
        _sessionRestoredController.add(null);
      }
    });

    _socket!.on('availability-change', (data) {
      _availabilityChangeController.add(Map<String, dynamic>.from(data));
    });

    _socket!.connect();
  }

  void requestMatch(String targetRole, String topic) {
    _socket?.emit('request-match', {
      'targetRole': targetRole,
      'topic': topic,
    });
  }

  void cancelMatch(String requestId) {
    _socket?.emit('cancel-match', {'requestId': requestId});
  }

  void acceptRequest(String requestId) {
    _socket?.emit('accept-request', {'requestId': requestId});
  }

  void declineRequest(String requestId) {
    _socket?.emit('decline-request', {'requestId': requestId});
  }

  void endSession(String sessionId) {
    _socket?.emit('end-session', {'sessionId': sessionId});
  }

  void setAvailability(bool isAvailable) {
    _socket?.emit('availability-change', {'isAvailable': isAvailable});
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }
}
