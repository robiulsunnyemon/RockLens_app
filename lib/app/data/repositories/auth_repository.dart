import 'package:get/get.dart';
import '../constants/api_endpoints.dart';
import '../models/api_response_model.dart';
import '../models/auth_response_model.dart';
import '../models/email_submit_response_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiClient _client = Get.find<ApiClient>();
  final StorageService _storage = Get.find<StorageService>();

  /// Submit operator email.
  /// If new user: registers account and sends 4-digit PIN via SMTP.
  /// If existing user: returns user status without sending a new PIN.
  Future<ApiResponse<EmailSubmitResponseModel>> submitEmail(String email) async {
    try {
      final response = await _client.post(
        ApiEndpoints.requestPin,
        {'email': email.trim().toLowerCase()},
      );

      if (response.isOk && response.body != null) {
        final result = EmailSubmitResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        await _storage.saveLastEmail(result.email);
        return ApiResponse.success(result, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Verify 4-digit PIN and obtain access + refresh tokens
  Future<ApiResponse<AuthResponseModel>> verifyPin({
    required String email,
    required String pin,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.verifyPin,
        {
          'email': email.trim().toLowerCase(),
          'pin': pin.trim(),
        },
      );

      if (response.isOk && response.body != null) {
        final authData = AuthResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );

        // Save tokens & user profile in offline storage
        await _storage.saveTokens(
          accessToken: authData.accessToken,
          refreshToken: authData.refreshToken,
        );
        await _storage.saveUser(authData.user);
        await _storage.saveLastEmail(authData.user.email);

        return ApiResponse.success(authData, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Resend 4-digit PIN to an unverified operator
  Future<ApiResponse<EmailSubmitResponseModel>> resendPin(String email) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resendPin,
        {'email': email.trim().toLowerCase()},
      );

      if (response.isOk && response.body != null) {
        final result = EmailSubmitResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        return ApiResponse.success(result, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Reset PIN for an already verified operator
  Future<ApiResponse<EmailSubmitResponseModel>> resetPin(String email) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resetPin,
        {'email': email.trim().toLowerCase()},
      );

      if (response.isOk && response.body != null) {
        final result = EmailSubmitResponseModel.fromJson(
          response.body as Map<String, dynamic>,
        );
        return ApiResponse.success(result, statusCode: response.statusCode);
      }

      return ApiResponse.error(
        _client.parseErrorMessage(response),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Connection error: $e');
    }
  }

  /// Logout operator and clear stored tokens
  Future<void> logout() async {
    await _storage.clearSession();
  }
}
