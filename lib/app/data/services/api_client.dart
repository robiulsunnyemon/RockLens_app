import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import '../constants/api_endpoints.dart';
import 'storage_service.dart';

class ApiClient extends GetConnect {
  StorageService get _storage => Get.find<StorageService>();

  bool _isRefreshing = false;

  @override
  void onInit() {
    super.onInit();
    baseUrl = ApiEndpoints.baseUrl;
    timeout = ApiEndpoints.timeout;

    // Request Interceptor: Attach Bearer token
    httpClient.addRequestModifier<dynamic>((Request request) async {
      request.headers['Accept'] = 'application/json';
      final token = _storage.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    // Response Interceptor: Handle 401 & Auto Token Refresh
    httpClient.addResponseModifier<dynamic>((request, response) async {
      if (response.statusCode == 401 && !_isRefreshing) {
        final refreshToken = _storage.refreshToken;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          _isRefreshing = true;
          try {
            final refreshResponse = await post(
              ApiEndpoints.refreshToken,
              {'refresh_token': refreshToken},
            );

            if (refreshResponse.isOk && refreshResponse.body != null) {
              final newAccess = refreshResponse.body['access_token'] as String?;
              final newRefresh = refreshResponse.body['refresh_token'] as String?;
              if (newAccess != null && newRefresh != null) {
                await _storage.saveTokens(
                  accessToken: newAccess,
                  refreshToken: newRefresh,
                );
                // Retry original request with new token
                request.headers['Authorization'] = 'Bearer $newAccess';
                return await httpClient.request(
                  request.url.path,
                  request.method,
                  body: request.bodyBytes,
                  headers: request.headers,
                );
              }
            }
          } catch (_) {
            await _storage.clearSession();
          } finally {
            _isRefreshing = false;
          }
        }
      }
      return response;
    });
  }

  /// Helper to extract user-friendly error messages from API response
  String parseErrorMessage(Response response) {
    if (response.body is Map && response.body['detail'] != null) {
      return response.body['detail'].toString();
    }
    if (response.statusText != null && response.statusText!.isNotEmpty) {
      return response.statusText!;
    }
    if (response.statusCode == null || response.statusCode == 0) {
      return 'Cannot connect to backend server. Ensure backend is running.';
    }
    return 'An unexpected server error occurred (${response.statusCode})';
  }
}
