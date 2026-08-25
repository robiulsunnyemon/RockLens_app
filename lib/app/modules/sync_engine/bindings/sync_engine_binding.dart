import 'package:get/get.dart';
import '../controllers/sync_engine_controller.dart';

class SyncEngineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SyncEngineController>(() => SyncEngineController());
  }
}
