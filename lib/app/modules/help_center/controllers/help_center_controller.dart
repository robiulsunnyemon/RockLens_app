import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';

class HelpMessage {
  final String role; // 'ai' or 'user'
  final String text;
  final String time;

  HelpMessage({
    required this.role,
    required this.text,
    required this.time,
  });
}

class HelpCenterController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final activeTab = 'ai'.obs; // 'ai', 'live', 'faq'
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final messages = <HelpMessage>[].obs;
  final isLiveConnected = false.obs;
  final connectingLive = false.obs;

  final quickPrompts = [
    'Mohs hardness test?',
    'Pyrite vs Chalcopyrite',
    'Offline sync guide',
    'Malachite acid reaction',
  ];

  final guideItems = [
    {
      'q': 'How does OTZAR APP identify minerals offline?',
      'a': 'OTZAR APP runs an embedded quantized MobileNetV3 CNN model directly on-device, extracting optical luster, cleavage planes, and geochemical color histograms without requiring cellular internet connectivity.',
    },
    {
      'q': 'How to perform field hardness scratch tests?',
      'a': 'Use standard field references: Fingernail (~2.5), Copper penny (~3.5), Pocket knife blade (~5.5), and Quartz crystal (~7.0). Clean the test groove to ensure powder residue is not mistaken for a scratch.',
    },
    {
      'q': 'What claim export formats are supported?',
      'a': 'Export Hub supports Full PDF Geological Reports, KML/GeoJSON files for ArcGIS Enterprise & QGIS, and tabular CSV datasets for laboratory assay logs.',
    },
    {
      'q': 'How do staged offline scans synchronize?',
      'a': 'Go to the Sync Engine tab. Ensure Wi-Fi or Cellular Data Sync is toggled on, then tap "Force Background Sync" to push batch records to the cloud database.',
    },
  ];

  String get operatorName => _storage.currentUser?.fullName ?? 'Dr. Robiulsunyemon';

  @override
  void onInit() {
    super.onInit();
    final timeStr = _getCurrentTime();
    messages.add(HelpMessage(
      role: 'ai',
      text: 'Hello $operatorName! I am your OTZAR APP AI Field Geologist Assistant. How can I help with your mineral scans, cleavage tests, or claim zones today?',
      time: timeStr,
    ));
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void switchTab(String tabId) {
    HapticFeedback.selectionClick();
    activeTab.value = tabId;
  }

  void sendMessage([String? textToSend]) {
    final text = textToSend ?? inputController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    final timeNow = _getCurrentTime();

    messages.add(HelpMessage(
      role: 'user',
      text: text,
      time: timeNow,
    ));

    inputController.clear();
    _scrollToBottom();

    // Generate intelligent AI response
    Future.delayed(const Duration(milliseconds: 600), () {
      final reply = _generateAiResponse(text);
      messages.add(HelpMessage(
        role: 'ai',
        text: reply,
        time: _getCurrentTime(),
      ));
      _scrollToBottom();
    });
  }

  String _generateAiResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('mohs') || lower.contains('hardness')) {
      return 'Mohs Scale Guide: Malachite is 3.5–4.0 (scratched by copper penny), Pyrite is 6.0–6.5 (scratches glass), and Quartz is 7.0. Always test on an unweathered fresh rock fracture.';
    } else if (lower.contains('offline') || lower.contains('sync')) {
      return 'OTZAR APP stores all scans locally with AES-256 encryption. Once satellite or cellular connectivity is detected, your queued specimen discoveries will automatically push to the FastAPI cloud database.';
    } else if (lower.contains('chalcopyrite') || lower.contains('pyrite')) {
      return 'Distinguishing Pyrite vs Chalcopyrite: Chalcopyrite has a greenish-black streak and Mohs 3.5–4.0 (softer), while Pyrite has a brownish-black streak and Mohs 6.0–6.5 (much harder).';
    } else if (lower.contains('malachite') || lower.contains('acid')) {
      return 'Acid Effervescence Test: Apply a single drop of 10% cold dilute HCl. Malachite will effervesce vigorously (releasing CO2 gas), whereas Chrysocolla or silicate minerals will show no fizz.';
    }
    return "I've analyzed your geological inquiry. Based on field telemetry in your survey zone, ensure you perform standard scratch hardness and streak plate tests to confirm mineral group.";
  }

  void connectLiveAgent() async {
    HapticFeedback.mediumImpact();
    connectingLive.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));
    connectingLive.value = false;
    isLiveConnected.value = true;
  }

  void disconnectLiveAgent() {
    HapticFeedback.lightImpact();
    isLiveConnected.value = false;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
