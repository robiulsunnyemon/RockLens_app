/// Centralized API Endpoints and Network Configuration for OTZAR App.
/// Control all API base URLs, paths, and timeouts from this single file.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL selection
  // 1. With USB debugging + "adb reverse tcp:8000 tcp:8000", use 'http://127.0.0.1:8000'
  // 2. Over local Wi-Fi network, use 'http://192.168.100.183:8000'
  // 3. For Android Emulator only, use 'http://10.0.2.2:8000'
  static String get baseUrl {
    return 'http://127.0.0.1:8000';
  }

  // API Version Prefix
  static const String apiV1 = '/api/v1';

  // Authentication Endpoints
  static const String requestPin = '$apiV1/auth/request-pin';
  static const String verifyPin = '$apiV1/auth/verify-pin';
  static const String refreshToken = '$apiV1/auth/refresh-token';
  static const String resendPin = '$apiV1/auth/resend-pin';
  static const String resetPin = '$apiV1/auth/reset-pin';

  // User & Profile Endpoints
  static const String userMe = '$apiV1/users/me';
  static const String userSettings = '$apiV1/users/me/settings';
  static const String userAvatar = '$apiV1/users/me/avatar';

  // System Health
  static const String health = '/health';

  // Timeouts
  static const Duration timeout = Duration(seconds: 15);
}
