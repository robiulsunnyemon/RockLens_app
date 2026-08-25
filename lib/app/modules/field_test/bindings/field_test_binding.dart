import 'package:get/get.dart';
import '../controllers/field_test_controller.dart';

class FieldTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FieldTestController>(() => FieldTestController());
  }
}
