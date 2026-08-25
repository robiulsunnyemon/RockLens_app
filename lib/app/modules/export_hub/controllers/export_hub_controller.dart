import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/widgets/otzar_dialog.dart';

class ExportFormatItem {
  final String id;
  final String name;
  final String desc;
  final String size;
  final int colorHex;

  const ExportFormatItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.size,
    required this.colorHex,
  });
}

class ExportHubController extends GetxController {
  final selectedFormats = <String>['pdf', 'kml'].obs;
  final selectedDateRange = '7d'.obs;
  final isExporting = false.obs;

  static const List<ExportFormatItem> formats = [
    ExportFormatItem(
      id: 'pdf',
      name: 'PDF Field Report',
      desc: 'Complete geological summary with photos, maps & analysis',
      size: '2.4 MB',
      colorHex: 0xFFE65100,
    ),
    ExportFormatItem(
      id: 'kml',
      name: 'KML / Shapefile',
      desc: 'ArcGIS & Google Earth compatible geospatial export',
      size: '0.8 MB',
      colorHex: 0xFF00C853,
    ),
    ExportFormatItem(
      id: 'csv',
      name: 'CSV Dataset',
      desc: 'Raw tabular data for Excel, QGIS & lab analysis',
      size: '48 KB',
      colorHex: 0xFF00E5FF,
    ),
    ExportFormatItem(
      id: 'json',
      name: 'GeoJSON Export',
      desc: 'Open-standard geospatial format for web & custom GIS',
      size: '112 KB',
      colorHex: 0xFFD4AF37,
    ),
  ];

  void toggleFormat(String id) {
    HapticFeedback.selectionClick();
    if (selectedFormats.contains(id)) {
      selectedFormats.remove(id);
    } else {
      selectedFormats.add(id);
    }
  }

  void setDateRange(String range) {
    HapticFeedback.selectionClick();
    selectedDateRange.value = range;
  }

  Future<void> exportSelected() async {
    if (selectedFormats.isEmpty || isExporting.value) return;

    HapticFeedback.heavyImpact();
    isExporting.value = true;

    // Simulate PDF / GIS export generation
    await Future.delayed(const Duration(milliseconds: 1800));
    isExporting.value = false;

    OtzarDialog.show(
      title: 'Report Generated',
      message:
          'Successfully generated ${selectedFormats.length} dataset bundle(s) for Zambia Copperbelt Survey. Stored in /Documents/OTZAR_Exports/.',
      confirmText: 'Done',
      type: OtzarDialogType.success,
    );
  }
}
