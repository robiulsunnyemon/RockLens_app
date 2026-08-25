import 'package:get/get.dart';

import '../modules/email_access/bindings/email_access_binding.dart';
import '../modules/email_access/views/email_access_view.dart';
import '../modules/main_nav/bindings/main_nav_binding.dart';
import '../modules/main_nav/views/main_nav_view.dart';
import '../modules/vault/bindings/vault_binding.dart';
import '../modules/vault/views/vault_view.dart';
import '../modules/gis_map/bindings/gis_map_binding.dart';
import '../modules/gis_map/views/gis_map_view.dart';
import '../modules/sync_engine/bindings/sync_engine_binding.dart';
import '../modules/sync_engine/views/sync_engine_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/pin_access/bindings/pin_access_binding.dart';
import '../modules/pin_access/views/pin_access_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/scanner/bindings/scanner_binding.dart';
import '../modules/scanner/views/scanner_view.dart';
import '../modules/processing/bindings/processing_binding.dart';
import '../modules/processing/views/processing_view.dart';
import '../modules/result/bindings/result_binding.dart';
import '../modules/result/views/result_view.dart';
import '../modules/field_test/bindings/field_test_binding.dart';
import '../modules/field_test/views/field_test_view.dart';
import '../modules/logging/bindings/logging_binding.dart';
import '../modules/logging/views/logging_view.dart';
import '../modules/export_hub/bindings/export_hub_binding.dart';
import '../modules/export_hub/views/export_hub_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_NAV,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.EMAIL_ACCESS,
      page: () => const EmailAccessView(),
      binding: EmailAccessBinding(),
    ),
    GetPage(
      name: _Paths.PIN_ACCESS,
      page: () => const PinAccessView(),
      binding: PinAccessBinding(),
    ),
    GetPage(
      name: _Paths.VAULT,
      page: () => const VaultView(),
      binding: VaultBinding(),
    ),
    GetPage(
      name: _Paths.GIS_MAP,
      page: () => const GisMapView(),
      binding: GisMapBinding(),
    ),
    GetPage(
      name: _Paths.SYNC_ENGINE,
      page: () => const SyncEngineView(),
      binding: SyncEngineBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SCANNER,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.PROCESSING,
      page: () => const ProcessingView(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: _Paths.RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: _Paths.FIELD_TEST,
      page: () => const FieldTestView(),
      binding: FieldTestBinding(),
    ),
    GetPage(
      name: _Paths.LOGGING,
      page: () => const LoggingView(),
      binding: LoggingBinding(),
    ),
    GetPage(
      name: _Paths.EXPORT_HUB,
      page: () => const ExportHubView(),
      binding: ExportHubBinding(),
    ),
  ];
}
