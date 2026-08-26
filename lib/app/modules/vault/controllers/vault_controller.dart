import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';

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

    // Load User's real logged discoveries exclusively
    final userLogs = _storage.getDiscoveryLogs();
    for (final log in userLogs) {
      final name = log['name'] as String? ?? 'Logged Specimen';
      items.add(SpecimenItem(
        name: name,
        formula: log['formula'] as String? ?? 'Mineral',
        conf: (log['conf'] as num?)?.toInt() ?? 92,
        grade: log['grade'] as String? ?? 'Specimen',
        date: log['date'] as String? ?? 'Recent',
        colorHex: _getMineralColorHex(name),
        synced: log['synced'] == true,
        loc: log['loc'] as String? ?? 'Discovery Zone',
        group: 'My Scans',
        regions: 'Logged In Field',
      ));
    }

    allSpecimens.assignAll(items);
  }

  int _getMineralColorHex(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('malachite')) return 0xFF00C853;
    if (lower.contains('tanzanite') || lower.contains('azurite')) return 0xFF6366F1;
    if (lower.contains('gold') || lower.contains('pyrite') || lower.contains('coltan')) return 0xFFD4AF37;
    if (lower.contains('bornite') || lower.contains('copper')) return 0xFFFF9100;
    if (lower.contains('chrysocolla') || lower.contains('tourmaline') || lower.contains('quartz')) return 0xFF00E5FF;
    if (lower.contains('biotite') || lower.contains('emerald')) return 0xFF10B981;
    return 0xFF00E5FF;
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
