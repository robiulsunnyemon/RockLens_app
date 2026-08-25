import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/main_nav_controller.dart';
import '../widgets/custom_bottom_nav.dart';
import '../../home/views/home_view.dart';
import '../../vault/views/vault_view.dart';
import '../../gis_map/views/gis_map_view.dart';
import '../../sync_engine/views/sync_engine_view.dart';
import '../../profile/views/profile_view.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              VaultView(),
              GisMapView(),
              SyncEngineView(),
              ProfileView(),
            ],
          )),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
