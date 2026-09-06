import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../values/app_dimensions.dart';
import 'otzar_cached_image.dart';
import '../../data/services/online_vision_service.dart';
import '../../modules/main_nav/controllers/main_nav_controller.dart';

class SpecimenDetailsSheet {
  SpecimenDetailsSheet._();

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) {
    HapticFeedback.mediumImpact();

    final name = data['name'] as String? ?? 'Mineral Specimen';
    final formula = data['formula'] as String? ?? '';
    final tag = data['tag'] as String? ?? '#SC-001';
    final conf = (data['conf'] as num?)?.toInt() ?? 90;
    final grade = data['grade'] as String? ?? 'Specimen';
    final date = data['date'] as String? ?? 'Field Recorded';
    final loc = data['loc'] as String? ?? 'Vein Discovery';
    final lat = data['lat'] as String? ?? '-12.9783°S';
    final lon = data['lon'] as String? ?? '028.6234°E';
    final city = data['city'] as String? ?? 'Field Sector';
    final country = data['country'] as String? ?? 'Mine Concession';
    final altitude = data['altitude'] as String? ?? '1,247m ASL';
    final notes = data['notes'] as String? ?? '';
    final isSynced = data['synced'] == true;
    final hasVoice = data['hasVoiceNote'] == true;
    final voiceDur = data['voiceDuration'] as String? ?? '00:00';

    final rawPhotos = data['photos'] as List<dynamic>?;
    final List<String> photos = [];
    if (rawPhotos != null) {
      for (final p in rawPhotos) {
        if (p != null && p.toString().isNotEmpty) {
          photos.add(p.toString());
        }
      }
    }
    if (photos.isEmpty && data['photo'] != null && data['photo'].toString().isNotEmpty) {
      photos.add(data['photo'].toString());
    }

    // Dynamic mineral properties from knowledge base
    Map<String, String> properties = {};
    String mineralGroup = 'GEOLOGICAL SPECIMEN';
    String estValue = r'$600 / kg';

    if (Get.isRegistered<OnlineVisionService>()) {
      final visionService = Get.find<OnlineVisionService>();
      final specimen = visionService.getSpecimenByLabel(name);
      properties = specimen.toPropertiesMap();
      mineralGroup = specimen.group;
      estValue = specimen.specimenEstimate;
    }

    final color = _getMineralColorHex(name);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14171F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.85),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Scrollable Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Header Bar (Tag, Sync Status & Close Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: color.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.monoTag.copyWith(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isSynced ? AppColors.emerald : AppColors.ember).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (isSynced ? AppColors.emerald : AppColors.ember).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                                    size: 10,
                                    color: isSynced ? AppColors.emerald : AppColors.ember,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSynced ? 'CLOUD SYNCED' : 'OFFLINE BUFFER',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: isSynced ? AppColors.emerald : AppColors.ember,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 20),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Mineral Name & Formula
                    Text(
                      mineralGroup.toUpperCase(),
                      style: AppTypography.hudTicker.copyWith(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.quartz,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (formula.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        formula,
                        style: AppTypography.monoSubtitle.copyWith(
                          color: AppColors.ore,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Photo Viewer Box
                    _buildPhotoHero(photos, color),
                    const SizedBox(height: 16),

                    // Match Confidence & Value Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.radius16,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('AI CONFIDENCE', '$conf% MATCH', color),
                          Container(width: 1, height: 28, color: AppColors.surfaceBorder),
                          _buildStatColumn('GRADE', grade.toUpperCase(), AppColors.quartz),
                          Container(width: 1, height: 28, color: AppColors.surfaceBorder),
                          _buildStatColumn('EST. VALUE', estValue, AppColors.emerald),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GPS Telemetry HUD Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.radius16,
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.satellite_alt_rounded, color: AppColors.ore, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'FIELD GPS TELEMETRY',
                                style: AppTypography.hudTicker.copyWith(
                                  color: AppColors.ore,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTelemetryCell('LATITUDE', lat)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTelemetryCell('LONGITUDE', lon)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildTelemetryCell('CITY / LOCALITY', city)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTelemetryCell('COUNTRY', country)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildTelemetryCell('ALTITUDE', altitude)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildTelemetryCell('ZONE / CONCESSION', loc)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTelemetryCell('LOG DATE & TIME', date),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Physical & Geological Properties
                    if (properties.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.radius16,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.science_outlined, color: AppColors.cyan, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'PHYSICAL & CRYSTALLINE PROPERTIES',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.cyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...properties.entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.key.toUpperCase(),
                                        style: AppTypography.hudTicker.copyWith(
                                          color: AppColors.subtle,
                                          fontSize: 9,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          e.value,
                                          textAlign: TextAlign.end,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.quartz,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Field Notes & Audio Note (if present)
                    if (notes.isNotEmpty || hasVoice) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.radius16,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.notes_rounded, color: AppColors.ore, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'FIELD OBSERVATIONS & AUDIO',
                                  style: AppTypography.hudTicker.copyWith(
                                    color: AppColors.ore,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            if (notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                notes,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.quartz,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (hasVoice) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.ore.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.ore.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.mic_rounded, color: AppColors.ore, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Voice Field Dictation ($voiceDur)',
                                      style: AppTypography.hudTicker.copyWith(
                                        color: AppColors.ore,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Buttons (View on Map & Close)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              if (Get.isRegistered<MainNavController>()) {
                                Get.find<MainNavController>().changePage(2);
                              }
                            },
                            icon: const Icon(Icons.map_outlined, size: 16),
                            label: const Text('VIEW ON GIS MAP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ore,
                              foregroundColor: AppColors.litho,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.r12),
                              ),
                              textStyle: AppTypography.hudTicker.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.r12),
                            ),
                          ),
                          child: Text(
                            'DISMISS',
                            style: AppTypography.hudTicker.copyWith(
                              color: AppColors.subtle,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildPhotoHero(List<String> photos, Color color) {
    if (photos.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppDimensions.radius20,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diamond_outlined, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                'NO SPECIMEN PHOTO CAPTURED',
                style: AppTypography.hudTicker.copyWith(
                  color: AppColors.subtle,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final photoUrl = photos.first;
    final isNetwork = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');

    return ClipRRect(
      borderRadius: AppDimensions.radius20,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            OtzarCachedImage(
              imageUrlOrPath: photoUrl,
              fit: BoxFit.cover,
              errorWidget: Center(
                child: Icon(Icons.broken_image_rounded, size: 40, color: color),
              ),
            ),
            // Source Badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  isNetwork ? 'CLOUDINARY CDN' : 'LOCAL FIELD RAW',
                  style: AppTypography.monoTag.copyWith(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.hudTicker.copyWith(
            color: AppColors.subtle,
            fontSize: 8.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.displayMedium.copyWith(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget _buildTelemetryCell(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252B3A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.hudTicker.copyWith(
              color: AppColors.muted,
              fontSize: 7.5,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.quartz,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Color _getMineralColorHex(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('malachite')) return const Color(0xFF00C853);
    if (lower.contains('tanzanite') || lower.contains('azurite')) return const Color(0xFF6366F1);
    if (lower.contains('gold') || lower.contains('pyrite') || lower.contains('coltan')) return const Color(0xFFD4AF37);
    if (lower.contains('bornite') || lower.contains('copper')) return const Color(0xFFFF9100);
    if (lower.contains('chrysocolla') || lower.contains('tourmaline') || lower.contains('quartz')) return const Color(0xFF00E5FF);
    if (lower.contains('biotite') || lower.contains('emerald')) return const Color(0xFF10B981);
    return const Color(0xFF00E5FF);
  }
}
