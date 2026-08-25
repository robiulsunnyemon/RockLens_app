import 'package:get/get.dart';
import '../controllers/logging_controller.dart';

class LoggingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoggingController>(() => LoggingController());
  }
}
