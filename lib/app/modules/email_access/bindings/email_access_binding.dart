import 'package:get/get.dart';
import '../controllers/email_access_controller.dart';

class EmailAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailAccessController>(() => EmailAccessController());
  }
}
