import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  UserModel? get currentUser => _storage.currentUser;

  String get operatorName => currentUser?.fullName ?? 'Dr. Robiul';
  String get initials {
    final parts = operatorName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return operatorName.isNotEmpty ? operatorName.substring(0, 2).toUpperCase() : 'DR';
  }
  String get designation => currentUser?.designation ?? 'Lead Exploration Geologist';
  String get companyName => currentUser?.companyName ?? 'Pan-African Mineral Consortium';

  // Reactive observable list for recent scans
  final recentScans = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentScans();
  }

  void loadRecentScans() {
    final logs = _storage.getDiscoveryLogs();
    if (logs.isNotEmpty) {
      final items = logs.map((log) => {
        'name': log['name'] ?? 'Specimen',
        'formula': log['formula'] ?? 'Mineral',
        'conf': log['conf'] ?? 92,
        'grade': log['grade'] ?? 'Specimen',
        'time': log['date'] ?? 'Recent',
        'color': _getMineralColorHex(log['name'] as String? ?? ''),
      }).toList();
      recentScans.assignAll(items);
      return;
    }

    recentScans.assignAll(const [
      {
        'name': 'Malachite',
        'formula': 'Cu₂CO₃(OH)₂',
        'conf': 86,
        'grade': 'Specimen',
        'time': '14:32',
        'color': 0xFF00C853,
      },
      {
        'name': 'Tanzanite',
        'formula': 'Ca₂Al₃(SiO₄)₃(OH)+V',
        'conf': 94,
        'grade': 'Gemstone',
        'time': '12:08',
        'color': 0xFF6366F1,
      },
      {
        'name': 'Pyrite',
        'formula': 'FeS₂',
        'conf': 78,
        'grade': 'Industrial',
        'time': '09:45',
        'color': 0xFFFF9100,
      },
    ]);
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

  void startScanning() {
    Get.toNamed(Routes.SCANNER);
  }

  void goToExportHub() {
    Get.toNamed(Routes.EXPORT_HUB);
  }

  void goToSync() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(3);
    }
  }

  void goToVault() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(1);
    }
  }

  void goToMap() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(2);
    }
  }

  void goToProfile() {
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changePage(4);
    }
  }
}
