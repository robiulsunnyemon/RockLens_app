import 'package:get/get.dart';
import '../constants/api_endpoints.dart';
import '../models/api_response_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiClient _client = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  /// Fetch authenticated operator's latest profile and settings
  Future<ApiResponse<UserModel>> getMyProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.userMe);

      if (response.isOk && response.body != null) {
        final user = UserModel.fromJson(response.body as Map<String, dynamic>);
        await _storage.saveUser(user);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Update profile details
  Future<ApiResponse<UserModel>> updateProfile({
    String? fullName,
    String? designation,
    String? companyName,
    String? teamName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (designation != null) body['designation'] = designation;
      if (companyName != null) body['company_name'] = companyName;
      if (teamName != null) body['team_name'] = teamName;

      final response = await _client.patch(ApiEndpoints.userMe, body);

      if (response.isOk && response.body != null) {
        final user = UserModel.fromJson(response.body as Map<String, dynamic>);
        await _storage.saveUser(user);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Update field and device settings
  Future<ApiResponse<UserModel>> updateSettings({
    bool? sunlightMode,
    bool? voiceLogging,
    bool? autoSync,
    String? offlineRegion,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (sunlightMode != null) body['sunlight_mode'] = sunlightMode;
      if (voiceLogging != null) body['voice_logging'] = voiceLogging;
      if (autoSync != null) body['auto_sync'] = autoSync;
      if (offlineRegion != null) body['offline_region'] = offlineRegion;

      final response = await _client.patch(ApiEndpoints.userSettings, body);

      if (response.isOk && response.body != null) {
        final user = UserModel.fromJson(response.body as Map<String, dynamic>);
        await _storage.saveUser(user);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Upload avatar image to Cloudinary via backend endpoint
  Future<ApiResponse<UserModel>> uploadAvatar({
    required List<int> fileBytes,
    required String filename,
  }) async {
    try {
      final form = FormData({
        'file': MultipartFile(fileBytes, filename: filename),
      });

      final response = await _client.post(ApiEndpoints.userAvatar, form);

      if (response.isOk && response.body != null) {
        final user = UserModel.fromJson(response.body as Map<String, dynamic>);
        await _storage.saveUser(user);
        return ApiResponse.success(user, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }
}
