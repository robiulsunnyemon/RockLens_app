import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../controllers/logging_controller.dart';

class LoggingView extends GetView<LoggingController> {
  const LoggingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      appBar: AppBar(
        backgroundColor: AppColors.litho,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.quartz),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'LOG DISCOVERY RECORD',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.quartz,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16, vertical: AppDimensions.p8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Specimen Photos Gallery (Dynamic Slots + Add Photo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      'SPECIMEN PHOTOS (${controller.specimenPhotos.length})',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    )),
                Text(
                  'TAP TO CAPTURE ANGLE',
                  style: AppTypography.hudTicker.copyWith(
                    color: AppColors.ore,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.p8),

            // Dynamic Photo List Row
            Obx(() {
              final photos = controller.specimenPhotos;
              return SizedBox(
                height: 72,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Render Captured Real Photos
                    ...photos.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final path = entry.value;
                      return Container(
                        width: 72,
                        height: 72,
                        margin: const EdgeInsets.only(right: AppDimensions.p8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                          border: Border.all(color: AppColors.emerald, width: 1.2),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.r16 - 1),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: AppColors.surface2,
                                  child: const Icon(Icons.broken_image_rounded, color: AppColors.muted, size: 24),
                                ),
                              ),
                            ),
                            // Remove Photo Badge
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () => controller.removeSpecimenPhoto(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                            // Angle tag
                            Positioned(
                              bottom: 3,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  idx == 0 ? 'Top' : idx == 1 ? 'Fracture' : 'Angle #${idx + 1}',
                                  style: AppTypography.monoFooter.copyWith(
                                    color: AppColors.ore,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Quick Angle Add Slots (If less than 3)
                    if (photos.length < 3)
                      ...List.generate(3 - photos.length, (i) {
                        final labels = ['Top view', 'Fracture', 'Texture'];
                        final label = labels[(photos.length + i) % labels.length];
                        return GestureDetector(
                          onTap: () => _showPhotoSourceBottomSheet(context),
                          child: Container(
                            width: 72,
                            height: 72,
                            margin: const EdgeInsets.only(right: AppDimensions.p8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.r16),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined, color: AppColors.muted, size: 20),
                                Positioned(
                                  bottom: 4,
                                  child: Text(
                                    label,
                                    style: AppTypography.monoFooter.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 7.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    // Extra + Add Photo Button
                    GestureDetector(
                      onTap: () => _showPhotoSourceBottomSheet(context),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.r16),
                          border: Border.all(
                            color: AppColors.ore.withValues(alpha: 0.4),
                            style: BorderStyle.solid,
                            width: 1.2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_rounded, color: AppColors.ore, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppDimensions.p16),

            // 2. Real Auto-Captured GPS & Environmental Metadata Grid
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.radius16,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AUTO-CAPTURED METADATA',
                        style: AppTypography.hudTicker.copyWith(
                          color: AppColors.ore,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Obx(() {
                        final isReady = controller.isLocationReady;
                        return GestureDetector(
                          onTap: controller.retryFetchLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isReady
                                  ? AppColors.emerald.withValues(alpha: 0.15)
                                  : AppColors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isReady
                                    ? AppColors.emerald.withValues(alpha: 0.4)
                                    : AppColors.amber.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isReady ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                                  color: isReady ? AppColors.emerald : AppColors.amber,
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isReady ? 'GPS FIXED' : 'ACQUIRING GPS',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: isReady ? AppColors.emerald : AppColors.amber,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Dynamic Live Metadata Items
                  Obx(() {
                    final items = controller.metadataItems;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.p12,
                        mainAxisSpacing: AppDimensions.p8,
                        childAspectRatio: 3.5,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        return Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                item['label']!,
                                style: AppTypography.monoFooter.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item['value']!,
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.quartz,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // 3. Dynamic Voice Field Note (Waveform & Timer)
            Container(
              padding: const EdgeInsets.all(AppDimensions.p16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.radius16,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VOICE FIELD NOTE',
                        style: AppTypography.hudTicker.copyWith(
                          color: AppColors.ore,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Obx(() => Text(
                            controller.isRecording.value
                                ? '${controller.formattedDuration} REC ●'
                                : controller.hasRecordedVoice.value
                                    ? '${controller.formattedDuration} SAVED'
                                    : '00:00',
                            style: AppTypography.monoFooter.copyWith(
                              color: controller.isRecording.value
                                  ? AppColors.rust
                                  : controller.hasRecordedVoice.value
                                      ? AppColors.emerald
                                      : AppColors.muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Animated Waveform Visualizer
                  Obx(() {
                    final rec = controller.isRecording.value;
                    final saved = controller.hasRecordedVoice.value;
                    return SizedBox(
                      height: 28,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(24, (i) {
                          final h = rec
                              ? (6.0 + ((i + controller.recordingDuration.value) % 7) * 3.2)
                              : saved
                                  ? (8.0 + (i % 4) * 2.5)
                                  : 4.0;
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: h,
                              decoration: BoxDecoration(
                                color: rec
                                    ? (i < 16 ? AppColors.rust : AppColors.ore)
                                    : saved
                                        ? AppColors.emerald
                                        : AppColors.surfaceBorder,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.p12),

                  // Record Action Button & Status Description
                  Row(
                    children: [
                      GestureDetector(
                        onTap: controller.toggleVoiceRecording,
                        child: Obx(() {
                          final rec = controller.isRecording.value;
                          final saved = controller.hasRecordedVoice.value;
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rec
                                  ? AppColors.rust.withValues(alpha: 0.25)
                                  : saved
                                      ? AppColors.emerald.withValues(alpha: 0.2)
                                      : AppColors.ore.withValues(alpha: 0.15),
                              border: Border.all(
                                color: rec
                                    ? AppColors.rust
                                    : saved
                                        ? AppColors.emerald
                                        : AppColors.ore,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                rec
                                    ? Icons.stop_rounded
                                    : saved
                                        ? Icons.mic_none_rounded
                                        : Icons.mic_rounded,
                                color: rec
                                    ? AppColors.rust
                                    : saved
                                        ? AppColors.emerald
                                        : AppColors.ore,
                                size: 22,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUDIO RECORDING',
                              style: AppTypography.hudTicker.copyWith(
                                color: AppColors.subtle,
                                fontSize: 7.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.isRecording.value
                                      ? 'Recording geological audio note... Tap stop when finished.'
                                      : controller.hasRecordedVoice.value
                                          ? 'Voice note captured (${controller.formattedDuration}). Tap mic to re-record.'
                                          : 'Tap mic button to dictate audio observation in field.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: controller.isRecording.value
                                        ? AppColors.rust
                                        : controller.hasRecordedVoice.value
                                            ? AppColors.emerald
                                            : AppColors.subtle,
                                    fontSize: 11,
                                    fontStyle: controller.isRecording.value
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // 4. Field Notes Text Input
            Text(
              'FIELD NOTES',
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.radius16,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: TextField(
                controller: controller.notesTextController,
                maxLines: 3,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.quartz, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add field observations, mineral strike angle, vein depth...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.subtle, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppDimensions.p14),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p16),

            // 5. Geological Tags Filter Chips
            Text(
              'GEOLOGICAL DEPOSIT TAGS',
              style: AppTypography.hudTicker.copyWith(
                color: AppColors.muted,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppDimensions.p8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LoggingController.availableTags.map((t) {
                return Obx(() {
                  final isSel = controller.selectedTags.contains(t);
                  return GestureDetector(
                    onTap: () => controller.toggleTag(t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.ore.withValues(alpha: 0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                        border: Border.all(
                          color: isSel ? AppColors.ore : AppColors.surfaceBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        t,
                        style: AppTypography.hudTicker.copyWith(
                          color: isSel ? AppColors.ore : AppColors.muted,
                          fontSize: 10,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.p24),

            // 6. Save Discovery Action Button
            Obx(() {
              final isReady = controller.isLocationReady;
              final latVal = controller.latitude.value;
              String buttonText = 'Save Discovery & Pin to Map';
              if (!isReady) {
                if (latVal.contains('Denied')) {
                  buttonText = 'Location Permission Denied';
                } else if (latVal.contains('Unavailable')) {
                  buttonText = 'GPS Telemetry Unavailable';
                } else {
                  buttonText = 'Acquiring GPS Telemetry...';
                }
              }

              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isReady ? controller.saveDiscovery : null,
                  icon: Icon(
                    isReady ? Icons.bookmark_added_rounded : Icons.location_searching_rounded,
                    size: 18,
                    color: isReady ? AppColors.litho : AppColors.muted,
                  ),
                  label: Text(
                    buttonText,
                    style: AppTypography.buttonText.copyWith(
                      color: isReady ? AppColors.litho : AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReady ? AppColors.ore : AppColors.surface,
                    disabledBackgroundColor: AppColors.surface,
                    foregroundColor: isReady ? AppColors.litho : AppColors.muted,
                    disabledForegroundColor: AppColors.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.radius16,
                      side: isReady
                          ? BorderSide.none
                          : const BorderSide(color: AppColors.surfaceBorder, width: 1),
                    ),
                    elevation: 0,
                  ),
                ),
              );
            }),
            const SizedBox(height: AppDimensions.p20),
          ],
        ),
      ),
    );
  }

  void _showPhotoSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r20)),
      ),
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20, vertical: AppDimensions.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD SPECIMEN PHOTO ANGLE',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.ore,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.p12),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.cyan),
                  title: const Text('Capture with Camera', style: TextStyle(color: AppColors.quartz)),
                  onTap: () {
                    Get.back();
                    controller.addSpecimenPhoto(source: ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.emerald),
                  title: const Text('Pick from Gallery', style: TextStyle(color: AppColors.quartz)),
                  onTap: () {
                    Get.back();
                    controller.addSpecimenPhoto(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
