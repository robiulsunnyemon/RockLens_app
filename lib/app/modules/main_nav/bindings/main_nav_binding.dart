import 'package:get/get.dart';
import '../controllers/main_nav_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../vault/controllers/vault_controller.dart';
import '../../gis_map/controllers/gis_map_controller.dart';
import '../../sync_engine/controllers/sync_engine_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainNavController>(MainNavController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<VaultController>(VaultController(), permanent: true);
    Get.put<GisMapController>(GisMapController(), permanent: true);
    Get.put<SyncEngineController>(SyncEngineController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
}
