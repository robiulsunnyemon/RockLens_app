import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rocklens_app/app/data/services/storage_service.dart';
import 'package:rocklens_app/rocklens_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  runApp(const RockLensApp());
}
