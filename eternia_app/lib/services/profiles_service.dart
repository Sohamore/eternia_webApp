import '../core/api_client.dart';
import '../core/api_error.dart';

class ProfilesService {
  final ApiClient _api;

  ProfilesService(this._api);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/profiles/me');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields) async {
    final response = await _api.patch('/profiles/me', data: fields);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> verifyStudentId({
    required String institutionId,
    required String idType,
    required String rawId,
    String? claimForUserId,
  }) async {
    // Client-side validation
    if (institutionId.isEmpty || idType.isEmpty || rawId.isEmpty) {
      throw ApiError(
        type: ApiErrorType.validation,
        message: 'institution_id, id_type, and raw_id are required',
      );
    }

    final response = await _api.post('/profiles/verify-student-id', data: {
      'institution_id': institutionId,
      'id_type': idType,
      'raw_id': rawId,
      if (claimForUserId != null) 'claim_for_user_id': claimForUserId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateEmergencyContact({
    String? emergencyName,
    String? emergencyPhone,
    String? emergencyRelation,
    bool contactIsSelf = false,
  }) async {
    final response = await _api.patch('/profiles/emergency-contact', data: {
      'emergency_name': emergencyName,
      'emergency_phone': emergencyPhone,
      'emergency_relation': emergencyRelation,
      'contact_is_self': contactIsSelf,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> validateSpocQr(String qrPayload) async {
    final response = await _api.post('/profiles/validate-spoc-qr', data: {
      'qr_payload': qrPayload,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getPrivateData() async {
    final response = await _api.get('/profiles/me/private');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> redeemReferral(String code) async {
    final response = await _api.post('/profiles/me/redeem-referral', data: {'code': code});
    return Map<String, dynamic>.from(response.data as Map);
  }
}
