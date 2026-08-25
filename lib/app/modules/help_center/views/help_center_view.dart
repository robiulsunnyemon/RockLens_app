import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../controllers/help_center_controller.dart';

class HelpCenterView extends GetView<HelpCenterController> {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.quartz),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '15 Help Center',
          style: AppTypography.hudTicker.copyWith(
            color: AppColors.ore,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. Top Segmented Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Obx(() {
                  final active = controller.activeTab.value;
                  return Row(
                    children: [
                      _buildTabItem(
                        id: 'ai',
                        label: '🤖 AI Assistant',
                        isActive: active == 'ai',
                        activeColor: AppColors.ore,
                      ),
                      _buildTabItem(
                        id: 'live',
                        label: '👨‍💼 Live Agent',
                        isActive: active == 'live',
                        activeColor: AppColors.cyan,
                      ),
                      _buildTabItem(
                        id: 'faq',
                        label: '📚 Guides',
                        isActive: active == 'faq',
                        activeColor: AppColors.emerald,
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),

            // 2. Tab Views
            Expanded(
              child: Obx(() {
                switch (controller.activeTab.value) {
                  case 'live':
                    return _buildLiveAgentTab();
                  case 'faq':
                    return _buildGuidesTab();
                  case 'ai':
                  default:
                    return _buildAiAssistantTab();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String id,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(id),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.hudTicker.copyWith(
                color: isActive ? AppColors.litho : AppColors.subtle,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Tab 1: AI Assistant Chat Interface
  Widget _buildAiAssistantTab() {
    return Column(
      children: [
        // Quick Prompts Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: controller.quickPrompts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final chip = controller.quickPrompts[idx];
              return InkWell(
                onTap: () => controller.sendMessage(chip),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.ore.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '⚡ $chip',
                      style: AppTypography.monoTag.copyWith(
                        color: AppColors.ore,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Chat Conversation Box
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141820),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Obx(() => ListView.separated(
                    controller: controller.scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final m = controller.messages[idx];
                      final isUser = m.role == 'user';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isUser ? AppColors.goldGradient : null,
                                color: isUser ? null : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isUser
                                    ? null
                                    : Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Text(
                                m.text,
                                style: AppTypography.bodySmall.copyWith(
                                  color: isUser ? AppColors.litho : AppColors.quartz,
                                  fontSize: 12,
                                  fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '${isUser ? "You" : "OTZAR AI"} · ${m.time}',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Input Box & Send Button (Fixed layout constraints)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: TextField(
                    controller: controller.inputController,
                    onSubmitted: (val) => controller.sendMessage(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.quartz,
                      fontSize: 12.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask geological questions...',
                      hintStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => controller.sendMessage(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.ore,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Send',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.litho,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Tab 2: Live Support Agent
  Widget _buildLiveAgentTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Obx(() {
          if (!controller.isLiveConnected.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Icon(Icons.support_agent_rounded, color: AppColors.cyan, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connect with Live Geological Desk',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Instant connection with senior exploration geologists via satellite link.',
                  style: AppTypography.hudTicker.copyWith(
                    color: AppColors.subtle,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Status Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      _buildLiveInfoRow('SUPPORT DESK STATUS', '● ONLINE (3 AGENTS)', AppColors.emerald),
                      const Divider(color: AppColors.surfaceBorder, height: 16),
                      _buildLiveInfoRow('AVG RESPONSE TIME', '< 45 SECONDS', AppColors.ore),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Start Button
                InkWell(
                  onTap: controller.connectingLive.value ? null : controller.connectLiveAgent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: controller.connectingLive.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.litho),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Establishing Satellite Link...',
                                  style: TextStyle(
                                    color: AppColors.litho,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Start Live Support Session',
                              style: AppTypography.buttonText.copyWith(
                                color: AppColors.litho,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          }

          // When Connected
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.emerald, width: 2),
                ),
                child: const Center(
                  child: Text('👨‍💼', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LIVE AGENT CONNECTED',
                style: AppTypography.hudTicker.copyWith(
                  color: AppColors.emerald,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Marcus Vance (Senior Geologist)',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Session ID: #OTZ-84920 · AES-256 Encrypted',
                style: AppTypography.monoTag.copyWith(
                  color: AppColors.muted,
                  fontSize: 8.5,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  '"Hello Dr. Robiulsunyemon! I\'m reviewing your latest Malachite fracture telemetry now. Let me know if you need confirmation on ore grading or strike/dip measurements."',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.quartz,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: controller.disconnectLiveAgent,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.ember.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      'End Live Session',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.ember,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLiveInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.hudTicker.copyWith(color: AppColors.muted, fontSize: 9)),
        Text(value, style: AppTypography.hudTicker.copyWith(color: valueColor, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Tab 3: Geological Guides & FAQs
  Widget _buildGuidesTab() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: controller.guideItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final item = controller.guideItems[idx];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['q']!,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.ore,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['a']!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.subtle,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
