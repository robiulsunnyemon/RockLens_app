part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const MAIN_NAV = _Paths.MAIN_NAV;
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const EMAIL_ACCESS = _Paths.EMAIL_ACCESS;
  static const PIN_ACCESS = _Paths.PIN_ACCESS;
  static const VAULT = _Paths.VAULT;
  static const GIS_MAP = _Paths.GIS_MAP;
  static const SYNC_ENGINE = _Paths.SYNC_ENGINE;
  static const PROFILE = _Paths.PROFILE;
  static const SCANNER = _Paths.SCANNER;
  static const PROCESSING = _Paths.PROCESSING;
  static const RESULT = _Paths.RESULT;
  static const FIELD_TEST = _Paths.FIELD_TEST;
  static const LOGGING = _Paths.LOGGING;
  static const EXPORT_HUB = _Paths.EXPORT_HUB;
  static const HELP_CENTER = _Paths.HELP_CENTER;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const MAIN_NAV = '/main-nav';
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const EMAIL_ACCESS = '/email-access';
  static const PIN_ACCESS = '/pin-access';
  static const VAULT = '/vault';
  static const GIS_MAP = '/gis-map';
  static const SYNC_ENGINE = '/sync-engine';
  static const PROFILE = '/profile';
  static const SCANNER = '/scanner';
  static const PROCESSING = '/processing';
  static const RESULT = '/result';
  static const FIELD_TEST = '/field-test';
  static const LOGGING = '/logging';
  static const EXPORT_HUB = '/export-hub';
  static const HELP_CENTER = '/help-center';
}
