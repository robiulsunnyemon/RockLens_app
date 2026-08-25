/// UserModel representing authenticated operator profile, field metrics, and device settings.
class UserModel {
  final String id;
  final String email;
  final bool isActive;
  final bool isVerified;
  final String fullName;
  final String designation;
  final String companyName;
  final String? avatarUrl;
  final String teamName;
  final int scansCount;
  final int mineralsCount;
  final int teamCount;
  final double storageUsedMb;
  final double storageTotalMb;
  final bool sunlightMode;
  final bool voiceLogging;
  final bool autoSync;
  final String offlineRegion;
  final String neuralVersion;
  final bool exportAllowed;
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isVerified,
    required this.fullName,
    required this.designation,
    required this.companyName,
    this.avatarUrl,
    required this.teamName,
    required this.scansCount,
    required this.mineralsCount,
    required this.teamCount,
    required this.storageUsedMb,
    required this.storageTotalMb,
    required this.sunlightMode,
    required this.voiceLogging,
    required this.autoSync,
    required this.offlineRegion,
    required this.neuralVersion,
    required this.exportAllowed,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      fullName: json['full_name'] as String? ?? 'Operator',
      designation: json['designation'] as String? ?? 'Exploration Geologist',
      companyName: json['company_name'] as String? ?? 'Geo Exploration Corp',
      avatarUrl: json['avatar_url'] as String?,
      teamName: json['team_name'] as String? ?? 'Survey Unit Alpha',
      scansCount: json['scans_count'] as int? ?? 0,
      mineralsCount: json['minerals_count'] as int? ?? 0,
      teamCount: json['team_count'] as int? ?? 1,
      storageUsedMb: (json['storage_used_mb'] as num?)?.toDouble() ?? 0.0,
      storageTotalMb: (json['storage_total_mb'] as num?)?.toDouble() ?? 5120.0,
      sunlightMode: json['sunlight_mode'] as bool? ?? false,
      voiceLogging: json['voice_logging'] as bool? ?? true,
      autoSync: json['auto_sync'] as bool? ?? false,
      offlineRegion: json['offline_region'] as String? ?? 'Global Base',
      neuralVersion: json['neural_version'] as String? ?? 'v4.2.1',
      exportAllowed: json['export_allowed'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_active': isActive,
      'is_verified': isVerified,
      'full_name': fullName,
      'designation': designation,
      'company_name': companyName,
      'avatar_url': avatarUrl,
      'team_name': teamName,
      'scans_count': scansCount,
      'minerals_count': mineralsCount,
      'team_count': teamCount,
      'storage_used_mb': storageUsedMb,
      'storage_total_mb': storageTotalMb,
      'sunlight_mode': sunlightMode,
      'voice_logging': voiceLogging,
      'auto_sync': autoSync,
      'offline_region': offlineRegion,
      'neural_version': neuralVersion,
      'export_allowed': exportAllowed,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? designation,
    String? companyName,
    String? avatarUrl,
    String? teamName,
    bool? sunlightMode,
    bool? voiceLogging,
    bool? autoSync,
    String? offlineRegion,
  }) {
    return UserModel(
      id: id,
      email: email,
      isActive: isActive,
      isVerified: isVerified,
      fullName: fullName ?? this.fullName,
      designation: designation ?? this.designation,
      companyName: companyName ?? this.companyName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      teamName: teamName ?? this.teamName,
      scansCount: scansCount,
      mineralsCount: mineralsCount,
      teamCount: teamCount,
      storageUsedMb: storageUsedMb,
      storageTotalMb: storageTotalMb,
      sunlightMode: sunlightMode ?? this.sunlightMode,
      voiceLogging: voiceLogging ?? this.voiceLogging,
      autoSync: autoSync ?? this.autoSync,
      offlineRegion: offlineRegion ?? this.offlineRegion,
      neuralVersion: neuralVersion,
      exportAllowed: exportAllowed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
