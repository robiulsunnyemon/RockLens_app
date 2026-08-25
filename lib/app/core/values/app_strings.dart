/// Centralized App strings and copy text.
abstract class AppStrings {
  AppStrings._();

  static const String appName = 'OTZAR APP';
  static const String appTagline = 'GEOLOGICAL INTELLIGENCE SYSTEM';
  static const String appSubtag = 'Know What You Found';
  static const String appVersion = 'v2.4.1 · BUILD 2024.08 · OFFLINE READY';

  // Splash ticker steps
  static const List<String> splashSteps = [
    'Initializing Neural Engine...',
    'Calibrating GPS Receiver...',
    'Loading Mineral Database...',
    'Engaging Offline Vault...',
    'System Ready.',
  ];

  // Onboarding slides
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

  // Pin Screen
  static const String fieldAccess = 'FIELD ACCESS';
  static const String secureLogin = 'OTZAR APP GEOLOGICAL SYSTEM — SECURE LOGIN';
  static const String pinHint = 'ENTER 4-DIGIT FIELD PIN';
  static const String biometric = 'BIOMETRIC';
  static const String invalidPin = 'Invalid PIN. Try again';
}
