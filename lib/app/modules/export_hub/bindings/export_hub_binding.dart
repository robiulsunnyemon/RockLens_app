import 'package:get/get.dart';
import '../controllers/export_hub_controller.dart';

class ExportHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExportHubController>(() => ExportHubController());
  }
}
