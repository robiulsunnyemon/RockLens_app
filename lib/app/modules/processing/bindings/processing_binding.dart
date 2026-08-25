import 'package:get/get.dart';
import '../controllers/processing_controller.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessingController>(() => ProcessingController());
  }
}
