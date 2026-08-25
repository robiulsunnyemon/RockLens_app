import 'package:get/get.dart';
import '../controllers/pin_access_controller.dart';

class PinAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinAccessController>(() => PinAccessController());
  }
}
