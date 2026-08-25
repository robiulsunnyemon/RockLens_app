import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otzar_app/app/data/services/storage_service.dart';
import 'package:otzar_app/otzar_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  runApp(const OtzarApp());
}
