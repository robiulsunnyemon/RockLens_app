import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/bindings/initial_binding.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

class RockLensApp extends StatelessWidget {
  const RockLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RockLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
