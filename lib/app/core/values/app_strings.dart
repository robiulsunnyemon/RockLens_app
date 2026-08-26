/// Centralized App strings, snackbar titles, messages, and copy text for OTZAR App.
abstract class AppStrings {
  AppStrings._();

  // General Brand & App Meta
  static const String appName = 'OTZAR APP';
  static const String appTagline = 'GEOLOGICAL INTELLIGENCE SYSTEM';
  static const String appSubtag = 'Know What You Found';
  static const String appVersion = 'v2.4.1 · BUILD 2026.08 · OFFLINE READY';

  // Splash Screen Ticker Steps
  static const List<String> splashSteps = [
    'Initializing Neural Engine...',
    'Calibrating GPS Receiver...',
    'Loading Mineral Database...',
    'Engaging Offline Vault...',
    'System Ready.',
  ];

  // Onboarding Slides
  static const String skip = 'SKIP →';
  static const String continueBtn = 'Continue';
  static const String accessSystemBtn = 'Access Field System';

  static const String slide1Tag = 'AI VISION CORE';
  static const String slide1Title = 'Instant Mineral Identification';
  static const String slide1Desc =
      'Point. Capture. Identify. Our on-device AI analyzes luster, cleavage, and crystal structure from multiple angles—delivering fast, reliable results without an internet connection.';

  static const String slide2Tag = 'OFFLINE RESILIENCE';
  static const String slide2Title = 'Zero-Network Field Logging';
  static const String slide2Desc =
      'Every scan, coordinate, and field note is encrypted locally and queued for smart sync when connectivity is restored. Work anywhere — Atacama, Pilbara, Copperbelt.';

  static const String slide3Tag = 'GIS VAULT';
  static const String slide3Title = 'Private Encrypted Claim Mapping';
  static const String slide3Desc =
      'Plot every discovery on an AES-256 encrypted topographic GIS map. Define exploration polygon boundaries, generate KML exports, and protect your mineral intelligence.';

  // Email Access Screen
  static const String emailAccessTitle = 'OPERATOR ACCESS';
  static const String emailAccessSubtitle = 'AUTHENTICATED FIELD OPERATOR LOGIN';
  static const String emailInputLabel = 'OPERATOR EMAIL';
  static const String emailInputHint = 'name@geological.corp';
  static const String emailSubmitBtn = '4-Digit Security PIN';
  static const String emailDirectPinBtn = 'Already have a PIN? Enter PIN directly →';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String emailSecurityNote = 'AES-256 ENCRYPTED SESSION · OFFLINE VAULT READY';
  static const String faceIdBiometricProtected = 'FACE ID & BIOMETRIC PROTECTED';
  static const String orUseBiometrics = 'OR USE BIOMETRICS';
  static const String oneTapFaceIdLogin = 'ONE-TAP FACE ID LOGIN';

  // PIN Access Screen
  static const String fieldAccess = 'FIELD ACCESS';
  static const String secureLogin = 'OTZAR APP GEOLOGICAL SYSTEM — SECURE LOGIN';
  static const String pinHint = 'ENTER 4-DIGIT FIELD PIN';
  static const String biometric = 'BIOMETRIC';
  static const String invalidPin = 'Invalid PIN. Try again';

  // Face ID & Biometrics
  static const String faceIdTitle = 'Face ID & Biometrics';
  static const String faceIdSubtitle = '1-tap facial recognition login';
  static const String facePromptRegister = 'Scan your face to register Face ID security for this operator.';
  static const String facePromptLogin = 'Scan face to unlock Otzar Geological Vault instantly';

  // -------------------------------------------------------------
  // SNACKBAR TITLES & MESSAGES
  // -------------------------------------------------------------

  // Face ID & Biometric Snackbars
  static const String snackBiometricsUnavailableTitle = 'Biometrics Unavailable';
  static const String snackBiometricsUnavailableMsg = 'Biometric hardware sensor is not detected on this device.';

  static const String snackFaceIdActivatedTitle = 'Face ID Activated';
  static const String snackFaceIdActivatedMsg = 'Face recognition security is now active for instant 1-tap login.';

  static const String snackFaceIdCancelledTitle = 'Face Registration Cancelled';
  static const String snackFaceIdCancelledMsg = 'Face ID verification was not completed.';

  static const String snackFaceIdDisabledTitle = 'Face ID Disabled';
  static const String snackFaceIdDisabledMsg = 'Standard Email and PIN credentials will be required for login.';

  static const String snackFaceIdAuthSuccessTitle = 'Face ID Authenticated';
  static String snackFaceIdAuthSuccessMsg(String name) => 'Welcome back, $name. Field telemetry unlocked.';

  static const String snackOfflineFaceUnlockTitle = 'Offline Face Unlock';
  static String snackOfflineFaceUnlockMsg(String name) => 'Welcome back, $name. Operating in offline field mode.';

  // Neural Model & OTA Engine Snackbars
  static const String snackNeuralEngineTitle = 'Neural Engine';
  static String snackNeuralEngineRunningMsg(String version) => 'Currently running local edge model ($version).';

  static const String snackNeuralModelUpgradedTitle = 'Neural Engine Upgraded!';
  static String snackNeuralModelUpgradedMsg(String version) => 'Successfully updated to model $version without restarting.';

  static const String snackNeuralModelUpToDateTitle = 'AI Model Up to Date ✓';
  static String snackNeuralModelUpToDateMsg(String version) => 'Inference engine is running the latest neural architecture ($version).';

  // Cloud Sync & Storage Engine Snackbars
  static const String snackSyncConfigTitle = 'Cloud Sync Config';
  static String snackAutoSyncEnabledMsg(int interval) => 'Automatic periodic sync enabled (${interval}m interval).';
  static const String snackAutoSyncDisabledMsg = 'Periodic background auto-sync disabled.';

  static const String snackCellularPolicyTitle = 'Cellular Policy';
  static String snackCellularPolicyMsg(bool enabled) => 'Cellular data sync ${enabled ? "enabled" : "disabled"}.';

  static const String snackAutoSyncTriggeredTitle = 'Auto-Sync Triggered';
  static String snackAutoSyncTriggeredMsg(int count) => 'All $count field logs successfully transmitted to Cloud.';

  static const String snackAllItemsSyncedTitle = 'All Items Synced';
  static const String snackAllItemsSyncedMsg = '0 items pending in offline queue.';

  static const String snackCloudSyncSuccessTitle = 'Cloud Sync Succeeded!';
  static String snackCloudSyncSuccessMsg(int count) => '$count specimen records successfully written to FastAPI Cloud Database.';

  static const String snackSyncNoticeTitle = 'Sync Notice';

  static const String snackOfflineModeActiveTitle = 'Offline Mode Active';
  static const String snackOfflineModeActiveMsg = 'Could not reach server. All logs remain encrypted locally in SQLite vault.';

  // Profile & User Settings Snackbars
  static const String snackAvatarUpdatedTitle = 'Avatar Updated';
  static const String snackAvatarUpdatedMsg = 'Profile photo updated locally and queued for cloud sync.';

  static const String snackAvatarSyncSuccessTitle = 'Avatar Upload Succeeded';
  static const String snackAvatarSyncSuccessMsg = 'Profile photo synchronized with Cloudinary CDN.';

  static const String snackAvatarErrorTitle = 'Avatar Error';
  static String snackAvatarErrorMsg(dynamic error) => 'Could not update photo: $error';

  static const String snackAvatarRemovedTitle = 'Avatar Removed';
  static const String snackAvatarRemovedMsg = 'Reverted to operator initials badge.';

  static const String snackProfileSyncedTitle = 'Profile Synced';
  static const String snackProfileSyncedMsg = 'Operator profile updated on FastAPI backend.';

  static const String snackProfileUpdatedTitle = 'Profile Updated';
  static const String snackProfileUpdatedMsg = 'Operator credentials updated locally and on cloud database.';

  static const String snackCachedLocallyTitle = 'Cached Locally';
  static const String snackCachedLocallyMsg = 'Updated on device. Staged for cloud sync when connection returns.';

  static const String snackCalibrationZeroedTitle = 'Calibration Zeroed';
  static const String snackCalibrationZeroedMsg = 'IMU & Gyroscope calibrated to true geological horizon.';

  static const String snackOfflineMapStoredTitle = 'Offline Map Stored';
  static String snackOfflineMapStoredMsg(String name, String size) => '$name ($size) downloaded and ready for offline exploration.';

  static const String snackMapRemovedTitle = 'Map Removed';
  static String snackMapRemovedMsg(String name) => '$name cache purged.';

  static const String snackPresetChangedTitle = 'Geochemical Preset Changed';
  static String snackPresetChangedMsg(String preset) => 'Spectral index updated to $preset';

  static const String snackTelemetryFilterTitle = 'Telemetry Filter Applied';
  static const String snackTelemetryFilterMsg = 'Telemetry HUD updated.';

  static const String snackProfileSavedTitle = 'Profile Updated ';
  static const String snackProfileSavedMsg = 'Field operator details saved.';

  static const String snackProfileResetTitle = 'Profile Reset';
  static const String snackProfileResetMsg = 'Reverted unsaved edits.';

  static const String snackSosAlertTitle = 'SOS Alert Broadcasted';
  static const String snackSosAlertMsg = 'Current GPS fix and operator ID dispatched to base-camp radio.';

  static const String snackCacheOptimizedTitle = 'Cache Optimized ';
  static const String snackCacheOptimizedMsg = 'Temporary cache and scan buffers cleaned. Storage freed.';

  static const String snackAccountDeactivatedTitle = 'Account Deactivated';
  static const String snackAccountDeactivatedMsg = 'Your account and cloud telemetry have been queued for deletion.';

  static const String snackDeletionQueuedTitle = 'Deletion Request Queued';
  static const String snackDeletionQueuedMsg = 'Session cleared. Admin notified of data erasure request.';

  static const String snackSessionTerminatedTitle = 'Session Terminated';
  static const String snackSessionTerminatedMsg = 'Operator successfully logged out from Otzar Field Station.';

  static const String snackArcGisTitle = 'ArcGIS Enterprise';
  static const String snackArcGisMsg = 'Concession geological database connected via REST API.';
}
