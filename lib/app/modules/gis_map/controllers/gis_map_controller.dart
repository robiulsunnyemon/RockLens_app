import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MapPin {
  final int id;
  final double xRatio; // 0.0 to 1.0
  final double yRatio; // 0.0 to 1.0
  final String name;
  final int colorHex;
  final int conf;
  final String bearing;
  final String elevation;
  final String date;

  const MapPin({
    required this.id,
    required this.xRatio,
    required this.yRatio,
    required this.name,
    required this.colorHex,
    required this.conf,
    required this.bearing,
    required this.elevation,
    required this.date,
  });
}

class GisMapController extends GetxController {
  final selectedPin = Rxn<MapPin>();
  final isDrawerOpen = true.obs;
  final isHeatmapActive = true.obs;

  final pins = const [
    MapPin(
      id: 1,
      xRatio: 0.46,
      yRatio: 0.32,
      name: 'Malachite',
      colorHex: 0xFF00C853,
      conf: 96,
      bearing: 'Katanga Crescent · DR Congo',
      elevation: '1,247m ASL',
      date: 'Active Deposit',
    ),
    MapPin(
      id: 2,
      xRatio: 0.68,
      yRatio: 0.29,
      name: 'Tanzanite',
      colorHex: 0xFF6366F1,
      conf: 98,
      bearing: 'Merelani Hills · Tanzania',
      elevation: '1,420m ASL',
      date: 'Exclusive Zone',
    ),
    MapPin(
      id: 3,
      xRatio: 0.38,
      yRatio: 0.48,
      name: 'Coltan',
      colorHex: 0xFFD4AF37,
      conf: 94,
      bearing: 'Kivu Mining Belt · DR Congo',
      elevation: '1,560m ASL',
      date: 'Strategic Reserve',
    ),
    MapPin(
      id: 4,
      xRatio: 0.52,
      yRatio: 0.72,
      name: 'Pyrite & Gold Reef',
      colorHex: 0xFFFF9100,
      conf: 88,
      bearing: 'Witwatersrand Basin · South Africa',
      elevation: '1,750m ASL',
      date: 'Major Reef',
    ),
    MapPin(
      id: 5,
      xRatio: 0.31,
      yRatio: 0.65,
      name: 'Quartz & Tourmaline',
      colorHex: 0xFF00E5FF,
      conf: 99,
      bearing: 'Brandberg Complex · Namibia',
      elevation: '2,573m ASL',
      date: 'Pegmatite Ridge',
    ),
    MapPin(
      id: 6,
      xRatio: 0.82,
      yRatio: 0.58,
      name: 'Biotite & Mica Pegmatite',
      colorHex: 0xFF10B981,
      conf: 91,
      bearing: 'Central Pegmatites · Madagascar',
      elevation: '1,120m ASL',
      date: 'Felsic Belt',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedPin.value = pins[0];
  }

  void selectPin(MapPin pin) {
    HapticFeedback.selectionClick();
    selectedPin.value = pin;
    isDrawerOpen.value = true;
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  void toggleHeatmap() {
    HapticFeedback.lightImpact();
    isHeatmapActive.value = !isHeatmapActive.value;
  }
}
