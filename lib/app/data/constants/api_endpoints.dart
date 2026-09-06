/// Centralized API Endpoints and Network Configuration for OTZAR App.
/// Control all API base URLs, paths, and timeouts from this single file.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL selection (Primary: PC LAN Wi-Fi IP, Secondary: localhost via ADB reverse)
  static String baseUrl = "https://api.otzarapp.com";
  static const String fallbackLocalUrl = 'https://api.otzarapp.com';

  // API Version Prefix
  static const String apiV1 = '/api/v1';

  // Authentication Endpoints
  static const String requestPin = '$apiV1/auth/request-pin';
  static const String verifyPin = '$apiV1/auth/verify-pin';
  static const String refreshToken = '$apiV1/auth/refresh-token';
  static const String resendPin = '$apiV1/auth/resend-pin';
  static const String resetPin = '$apiV1/auth/reset-pin';
  static const String logout = '$apiV1/auth/logout';
  static const String biometricVerify = '$apiV1/auth/biometric-verify';

  // User & Profile Endpoints
  static const String userMe = '$apiV1/users/me';
  static const String userSettings = '$apiV1/users/me/settings';
  static const String userAvatar = '$apiV1/users/me/avatar';
  static const String deleteAccount = '$apiV1/users/me';

  // Specimens & Cloud Sync Endpoints
  static const String syncBatch = '$apiV1/sync/batch';
  static const String specimens = '$apiV1/specimens';
  static const String identifySpecimen = '$apiV1/specimens/identify';

  // AI & Neural Model OTA Endpoints
  static const String neuralModelLatest = '$apiV1/ai/neural-model-latest';

  // System Health
  static const String health = '/health';

  // Timeouts
  static const Duration timeout = Duration(seconds: 15);
}
