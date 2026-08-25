/// Centralized API Endpoints and Network Configuration for OTZAR App.
/// Control all API base URLs, paths, and timeouts from this single file.
abstract class ApiEndpoints {
  ApiEndpoints._();

  // Base URL selection (Primary: PC LAN Wi-Fi IP, Secondary: localhost via ADB reverse)
  // static String baseUrl = 'http://192.168.100.183:8000';
  static String baseUrl = 'http://rnszxgbajam1misuba74j3ap.72.61.169.133.sslip.io';
  // static const String fallbackLocalUrl = 'http://127.0.0.1:8000';
  static const String fallbackLocalUrl = 'http://rnszxgbajam1misuba74j3ap.72.61.169.133.sslip.io';

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
  static const String deleteAccount = '$apiV1/users/me';

  // Specimens & Cloud Sync Endpoints
  static const String syncBatch = '$apiV1/sync/batch';
  static const String specimens = '$apiV1/specimens';

  // System Health
  static const String health = '/health';

  // Timeouts
  static const Duration timeout = Duration(seconds: 15);
}
