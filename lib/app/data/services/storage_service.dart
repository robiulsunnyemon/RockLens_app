import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'current_user';
  static const String _keyLastEmail = 'last_email';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Tokens
  String? get accessToken => _box.read<String>(_keyAccessToken);
  String? get refreshToken => _box.read<String>(_keyRefreshToken);
  String? get lastEmail => _box.read<String>(_keyLastEmail);

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.write(_keyAccessToken, accessToken);
    await _box.write(_keyRefreshToken, refreshToken);
  }

  Future<void> saveLastEmail(String email) async {
    await _box.write(_keyLastEmail, email);
  }

  // User Profile
  UserModel? get currentUser {
    final userJson = _box.read<String>(_keyUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _box.write(_keyUser, jsonEncode(user.toJson()));
  }

  static const String _keyDiscoveryLogs = 'discovery_logs';

  // Discovery Logs
  List<Map<String, dynamic>> getDiscoveryLogs() {
    final raw = _box.read<List<dynamic>>(_keyDiscoveryLogs);
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveDiscoveryLog(Map<String, dynamic> log) async {
    final logs = getDiscoveryLogs();
    logs.insert(0, log);
    await _box.write(_keyDiscoveryLogs, logs);
  }

  Future<void> markLogsAsSynced(List<String> tags) async {
    final logs = getDiscoveryLogs();
    for (final l in logs) {
      if (tags.contains(l['tag'])) {
        l['synced'] = true;
      }
    }
    await _box.write(_keyDiscoveryLogs, logs);
  }

  Future<void> markAllLogsAsSynced() async {
    final logs = getDiscoveryLogs();
    for (final l in logs) {
      l['synced'] = true;
    }
    await _box.write(_keyDiscoveryLogs, logs);
  }

  // Clear session
  Future<void> clearSession() async {
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUser);
  }

  // Clear all storage box data
  Future<void> clearAll() async {
    await _box.erase();
  }
}
