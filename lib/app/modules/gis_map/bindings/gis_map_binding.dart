import 'package:get/get.dart';
import '../controllers/gis_map_controller.dart';

class GisMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GisMapController>(() => GisMapController());
  }
}
