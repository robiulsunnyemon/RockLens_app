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
    Get.lazyPut<MainNavController>(() => MainNavController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<VaultController>(() => VaultController());
    Get.lazyPut<GisMapController>(() => GisMapController());
    Get.lazyPut<SyncEngineController>(() => SyncEngineController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
