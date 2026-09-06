import 'package:get/get.dart';
import '../../data/services/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

import '../../data/services/online_vision_service.dart';
import '../../data/services/face_auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<OnlineVisionService>(() => OnlineVisionService(), fenix: true);
    Get.lazyPut<FaceAuthService>(() => FaceAuthService(), fenix: true);
  }
}
