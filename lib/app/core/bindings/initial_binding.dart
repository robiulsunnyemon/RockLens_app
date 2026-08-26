import 'package:get/get.dart';
import '../../data/services/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

import '../../data/services/tflite_classifier_service.dart';
import '../../data/services/neural_model_sync_service.dart';
import '../../data/services/face_auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<TfliteClassifierService>(() => TfliteClassifierService(), fenix: true);
    Get.lazyPut<NeuralModelSyncService>(() => NeuralModelSyncService(), fenix: true);
    Get.lazyPut<FaceAuthService>(() => FaceAuthService(), fenix: true);
  }
}
