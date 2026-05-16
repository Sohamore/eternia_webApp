import '../core/api_client.dart';

class NotificationsService {
  final ApiClient _api;

  NotificationsService(this._api);

  Future<Map<String, dynamic>> getNotifications({int limit = 50}) async {
    final response = await _api.get('/notifications', queryParameters: {'limit': limit});
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final response = await _api.patch('/notifications/$id/read');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await _api.patch('/notifications/read-all');
    return Map<String, dynamic>.from(response.data as Map);
  }

  int getUnreadCount(List<Map<String, dynamic>> notifications) {
    return notifications.where((n) => n['is_read'] == false).length;
  }
}
