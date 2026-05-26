import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/socket_service.dart';

class SocketProvider extends ChangeNotifier {
  final SocketService _socketService;
  
  bool _isConnected = false;
  bool _isAvailable = false;
  
  Map<String, dynamic>? _activeSession;
  Map<String, dynamic>? _incomingRequest;
  
  String? _lastError;
  String? _pendingRequestId;

  List<StreamSubscription> _subscriptions = [];

  SocketProvider(this._socketService) {
    _initListeners();
  }

  bool get isConnected => _isConnected;
  bool get isAvailable => _isAvailable;
  Map<String, dynamic>? get activeSession => _activeSession;
  Map<String, dynamic>? get incomingRequest => _incomingRequest;
  String? get lastError => _lastError;
  String? get pendingRequestId => _pendingRequestId;
  
  bool get isMatchmaking => _pendingRequestId != null;

  void _initListeners() {
    _subscriptions.add(_socketService.connectionState.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    }));

    _subscriptions.add(_socketService.incomingRequest.listen((data) {
      _incomingRequest = data;
      notifyListeners();
    }));

    _subscriptions.add(_socketService.sessionStarted.listen((data) {
      _activeSession = data;
      _pendingRequestId = null;
      _incomingRequest = null;
      notifyListeners();
    }));

    _subscriptions.add(_socketService.requestCancelled.listen((reqId) {
      if (_incomingRequest != null && _incomingRequest!['requestId'] == reqId) {
        _incomingRequest = null;
        notifyListeners();
      }
      if (_pendingRequestId == reqId) {
        _pendingRequestId = null;
        notifyListeners();
      }
    }));

    _subscriptions.add(_socketService.requestExpired.listen((msg) {
      _lastError = msg;
      _incomingRequest = null;
      notifyListeners();
    }));

    _subscriptions.add(_socketService.sessionEnded.listen((sessionId) {
      if (_activeSession != null && _activeSession!['sessionId'] == sessionId) {
        _activeSession = null;
        notifyListeners();
      }
    }));

    _subscriptions.add(_socketService.matchFailed.listen((reason) {
      _lastError = reason;
      _pendingRequestId = null;
      notifyListeners();
    }));

    _subscriptions.add(_socketService.sessionRestored.listen((data) {
      if (data != null) {
        _activeSession = data;
      } else {
        _activeSession = null;
      }
      notifyListeners();
    }));

    _subscriptions.add(_socketService.availabilityChange.listen((data) {
      // In a real app we might check if this is our user, but for now we just 
      // rely on the local state update when we toggle it, or handle it here if needed.
    }));
  }

  Future<void> connect() async {
    _lastError = null;
    await _socketService.connect();
  }

  void disconnect() {
    _socketService.disconnect();
    _isConnected = false;
    _activeSession = null;
    _incomingRequest = null;
    _pendingRequestId = null;
    notifyListeners();
  }

  void toggleAvailability(bool available) {
    _isAvailable = available;
    _socketService.setAvailability(available);
    notifyListeners();
  }

  void requestMatch(String targetRole, String topic) {
    _lastError = null;
    // We generate a temp id or rely on backend event to set _pendingRequestId
    _pendingRequestId = 'pending_${DateTime.now().millisecondsSinceEpoch}'; 
    _socketService.requestMatch(targetRole, topic);
    notifyListeners();
  }

  void cancelMatch() {
    if (_pendingRequestId != null) {
      // We don't have the real requestId yet if it's async, but backend handles it by user
      // Alternatively, we wait for request-created on student side? No, student just calls cancel-match.
      _socketService.cancelMatch(_pendingRequestId!);
      _pendingRequestId = null;
      notifyListeners();
    }
  }

  void acceptRequest() {
    if (_incomingRequest != null) {
      _socketService.acceptRequest(_incomingRequest!['requestId']);
      // Keep it around until session-started confirms, or clear it
    }
  }

  void declineRequest() {
    if (_incomingRequest != null) {
      _socketService.declineRequest(_incomingRequest!['requestId']);
      _incomingRequest = null;
      notifyListeners();
    }
  }

  void endSession() {
    if (_activeSession != null) {
      _socketService.endSession(_activeSession!['sessionId']);
      _activeSession = null;
      notifyListeners();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
