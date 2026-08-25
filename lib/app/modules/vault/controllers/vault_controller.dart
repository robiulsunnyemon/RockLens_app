import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/tflite_classifier_service.dart';

class SpecimenItem {
  final String name;
  final String formula;
  final int conf;
  final String grade;
  final String date;
  final int colorHex;
  final bool synced;
  final String loc;
  final String group;
  final String regions;

  const SpecimenItem({
    required this.name,
    required this.formula,
    required this.conf,
    required this.grade,
    required this.date,
    required this.colorHex,
    required this.synced,
    required this.loc,
    this.group = 'General',
    this.regions = 'Pan-African',
  });
}

class VaultController extends GetxController {
  final TfliteClassifierService _classifier = Get.find<TfliteClassifierService>();
  final StorageService _storage = Get.find<StorageService>();

  final searchTextController = TextEditingController();
  final isCardView = true.obs;
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;

  final filters = const [
    'All',
    'My Scans',
    'Gemstones',
    'Copper Ores',
    'Carbonates',
    'Silicates',
  ];

  final allSpecimens = <SpecimenItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCatalogAndDiscoveries();
  }

  void loadCatalogAndDiscoveries() {
    final List<SpecimenItem> items = [];

    // 1. Load User's logged discoveries
    final userLogs = _storage.getDiscoveryLogs();
    for (final log in userLogs) {
      items.add(SpecimenItem(
        name: log['name'] ?? 'Logged Specimen',
        formula: log['formula'] ?? 'Mineral',
        conf: (log['conf'] as num?)?.toInt() ?? 92,
        grade: log['grade'] ?? 'Specimen',
        date: log['date'] ?? 'Recent',
        colorHex: 0xFF00E5FF,
        synced: log['synced'] ?? true,
        loc: log['loc'] ?? 'Discovery Zone',
        group: 'My Scans',
        regions: 'Logged In Field',
      ));
    }

    // 2. Load all minerals from Knowledge Base (minerals_db.json)
    final db = _classifier.mineralDatabase;
    final colorPalette = [
      0xFF00C853, // Green
      0xFF00E5FF, // Cyan
      0xFFD4AF37, // Gold
      0xFFFF9100, // Orange
      0xFF6366F1, // Indigo
      0xFFEC4899, // Pink
      0xFF10B981, // Emerald
      0xFFEAB308, // Yellow
    ];

    int colorIdx = 0;
    db.forEach((key, specimen) {
      // Avoid duplicating if already in user logs as first item
      final color = colorPalette[colorIdx % colorPalette.length];
      colorIdx++;

      items.add(SpecimenItem(
        name: specimen.name,
        formula: specimen.chemicalFormula,
        conf: 95,
        grade: specimen.rarityTier.contains('Rare') || specimen.rarityTier.contains('Gem')
            ? 'Gemstones'
            : specimen.group.contains('ORE') || specimen.group.contains('COPPER')
                ? 'Copper Ores'
                : 'Catalog',
        date: 'African Index',
        colorHex: color,
        synced: true,
        loc: specimen.africanRegions.isNotEmpty ? specimen.africanRegions.first : 'Africa',
        group: specimen.group,
        regions: specimen.africanRegions.join(', '),
      ));
    });

    allSpecimens.assignAll(items);
  }

  List<SpecimenItem> get filteredSpecimens {
    final query = searchQuery.value.toLowerCase().trim();
    final filter = selectedFilter.value;

    return allSpecimens.where((s) {
      final matchesSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.formula.toLowerCase().contains(query) ||
          s.loc.toLowerCase().contains(query) ||
          s.group.toLowerCase().contains(query) ||
          s.regions.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      if (filter == 'All') return true;
      if (filter == 'My Scans') return s.group == 'My Scans' || s.date != 'African Index';
      if (filter == 'Gemstones') return s.grade == 'Gemstones' || s.group.toLowerCase().contains('gem') || s.name.toLowerCase().contains('tanzanite') || s.name.toLowerCase().contains('quartz');
      if (filter == 'Copper Ores') return s.grade == 'Copper Ores' || s.group.toLowerCase().contains('cu') || s.formula.contains('Cu');
      if (filter == 'Carbonates') return s.group.toLowerCase().contains('carbonate') || s.formula.contains('CO₃');
      if (filter == 'Silicates') return s.group.toLowerCase().contains('silicate') || s.formula.contains('SiO');

      return true;
    }).toList();
  }

  void toggleViewMode(bool card) {
    isCardView.value = card;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
