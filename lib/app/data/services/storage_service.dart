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
  static const String _keyLocalAvatarPath = 'local_avatar_path';
  static const String _keyAvatarPendingSync = 'avatar_pending_sync';
  static const String _keyPendingAvatarPath = 'pending_avatar_path';
  static const String _keyCellularSync = 'cellular_sync_enabled';

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
    await _box.write(_keyBiometricToken, refreshToken);
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

  // Offline Avatar Management
  String? get localAvatarPath => _box.read<String>(_keyLocalAvatarPath);

  Future<void> saveLocalAvatarPath(String? path) async {
    if (path == null || path.isEmpty) {
      await _box.remove(_keyLocalAvatarPath);
    } else {
      await _box.write(_keyLocalAvatarPath, path);
    }
  }

  bool get isAvatarPendingSync => _box.read<bool>(_keyAvatarPendingSync) ?? false;
  String? get pendingAvatarPath => _box.read<String>(_keyPendingAvatarPath);

  Future<void> setAvatarPendingSync(bool pending, {String? path}) async {
    await _box.write(_keyAvatarPendingSync, pending);
    if (path != null && pending) {
      await _box.write(_keyPendingAvatarPath, path);
    } else if (!pending) {
      await _box.remove(_keyPendingAvatarPath);
    }
  }

  Future<void> clearPendingAvatarSync() async {
    await _box.remove(_keyAvatarPendingSync);
    await _box.remove(_keyPendingAvatarPath);
  }

  // Offline Profile Credentials Sync Management
  static const String _keyProfilePendingSync = 'profile_pending_sync';

  bool get isProfilePendingSync => _box.read<bool>(_keyProfilePendingSync) ?? false;

  Future<void> setProfilePendingSync(bool pending) async {
    await _box.write(_keyProfilePendingSync, pending);
  }

  // Cellular Sync Preference
  bool get isCellularSyncEnabled => _box.read<bool>(_keyCellularSync) ?? true;

  Future<void> setCellularSyncEnabled(bool enabled) async {
    await _box.write(_keyCellularSync, enabled);
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

  Future<void> updateDiscoveryLogPhotos(String tag, List<String> photos) async {
    final logs = getDiscoveryLogs();
    for (final l in logs) {
      if (l['tag'] == tag) {
        l['photos'] = photos;
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

  // Neural Model Versioning
  static const String _keyActiveNeuralVersion = 'active_neural_version';
  static const String _keyLastModelSyncDate = 'last_model_sync_date';

  String get activeNeuralVersion => _box.read<String>(_keyActiveNeuralVersion) ?? 'v4.2.1';
  Future<void> setActiveNeuralVersion(String version) async {
    await _box.write(_keyActiveNeuralVersion, version);
  }

  String get lastModelSyncDate => _box.read<String>(_keyLastModelSyncDate) ?? '26 Aug 2026';
  Future<void> setLastModelSyncDate(String date) async {
    await _box.write(_keyLastModelSyncDate, date);
  }

  // Face ID & Biometrics
  static const String _keyFaceIdEnabled = 'face_id_enabled';
  static const String _keyBiometricToken = 'biometric_session_token';

  bool get isFaceIdEnabled => _box.read<bool>(_keyFaceIdEnabled) ?? false;
  Future<void> setFaceIdEnabled(bool enabled) async {
    await _box.write(_keyFaceIdEnabled, enabled);
  }

  String? get savedBiometricToken => _box.read<String>(_keyBiometricToken) ?? refreshToken;
  Future<void> saveBiometricToken(String token) async {
    await _box.write(_keyBiometricToken, token);
  }

  // Clear session
  Future<void> clearSession() async {
    await _box.remove(_keyAccessToken);
    await _box.remove(_keyRefreshToken);
    await _box.remove(_keyUser);
    await _box.remove(_keyLocalAvatarPath);
    await _box.remove(_keyAvatarPendingSync);
    await _box.remove(_keyPendingAvatarPath);
  }

  // Clear all storage box data
  Future<void> clearAll() async {
    await _box.erase();
  }
}
