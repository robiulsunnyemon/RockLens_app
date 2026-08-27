import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/values/app_dimensions.dart';
import '../../../core/widgets/otzar_cached_image.dart';
import '../../../core/widgets/specimen_details_sheet.dart';
import '../controllers/vault_controller.dart';

class VaultView extends GetView<VaultController> {
  const VaultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.litho,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppColors.ore,
          backgroundColor: AppColors.surface,
          displacement: 20,
          child: Column(
            children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.p16,
                vertical: AppDimensions.p12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discovery Vault',
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // View mode switcher
                  Obx(() {
                    final isCard = controller.isCardView.value;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.radius12,
                        border: Border.all(
                          color: AppColors.surfaceBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: isCard ? AppColors.ore : AppColors.muted,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => controller.toggleViewMode(true),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.view_list_rounded,
                              size: 20,
                              color: !isCard ? AppColors.ore : AppColors.muted,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => controller.toggleViewMode(false),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(
                    color: AppColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller.searchTextController,
                  onChanged: controller.onSearchChanged,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.quartz,
                  ),
                  cursorColor: AppColors.ore,
                  decoration: InputDecoration(
                    hintText: 'Search minerals, formulas, veins...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.subtle,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.muted,
                          size: 18,
                        ),
                        onPressed: () {
                          controller.searchTextController.clear();
                          controller.onSearchChanged('');
                        },
                      );
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p16,
                      vertical: AppDimensions.p12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.p12),

            // Filter Tabs
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
                itemCount: controller.filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppDimensions.p8),
                itemBuilder: (context, index) {
                  final filter = controller.filters[index];
                  return Obx(() {
                    final isSelected = controller.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => controller.setFilter(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p14,
                          vertical: AppDimensions.p6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.ore : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.rFull),
                          border: Border.all(
                            color: isSelected ? AppColors.ore : AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: AppTypography.hudTicker.copyWith(
                            color: isSelected ? AppColors.litho : AppColors.subtle,
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: AppDimensions.p12),

            // Specimen Count Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
              child: Obx(() {
                final count = controller.filteredSpecimens.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count SPECIMENS FOUND',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.subtle,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'SORTED: DATE DESC',
                      style: AppTypography.hudTicker.copyWith(
                        color: AppColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: AppDimensions.p8),

            // Specimens Grid/List
            Expanded(
              child: Obx(() {
                final specimens = controller.filteredSpecimens;
                final isCard = controller.isCardView.value;

                if (specimens.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.muted,
                              ),
                              const SizedBox(height: AppDimensions.p12),
                              Text(
                                'No matching mineral specimens',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.subtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (isCard) {
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.p16,
                      vertical: AppDimensions.p8,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDimensions.p12,
                      crossAxisSpacing: AppDimensions.p12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: specimens.length,
                    itemBuilder: (context, index) {
                      final item = specimens[index];
                      final color = Color(item.colorHex);

                      return GestureDetector(
                        onTap: () => SpecimenDetailsSheet.show(context, data: item.toMap()),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.p12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppDimensions.radius20,
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vector Crystal or Real Photo Box
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: AppDimensions.radius12,
                                  border: Border.all(
                                    color: color.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: (item.photo != null && item.photo!.isNotEmpty)
                                    ? OtzarCachedImage(
                                        imageUrlOrPath: item.photo!,
                                        width: double.infinity,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(AppDimensions.r12 - 1),
                                        errorWidget: Center(
                                          child: Icon(Icons.diamond_outlined, size: 32, color: color),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.diamond_outlined,
                                          size: 32,
                                          color: color,
                                        ),
                                      ),
                              ),
                              const Spacer(),

                              // Name & Formula
                              Text(
                                item.name,
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.formula,
                                style: AppTypography.monoTag.copyWith(
                                  color: AppColors.subtle,
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),

                              // Bottom Row: Confidence & Sync Dot
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.conf}% MATCH',
                                    style: AppTypography.hudTicker.copyWith(
                                      color: color,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: item.synced
                                          ? AppColors.emerald
                                          : AppColors.ember,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                // List View
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.p16,
                    vertical: AppDimensions.p8,
                  ),
                  itemCount: specimens.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.p8),
                  itemBuilder: (context, index) {
                    final item = specimens[index];
                    final color = Color(item.colorHex);

                    return GestureDetector(
                      onTap: () => SpecimenDetailsSheet.show(context, data: item.toMap()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.p12,
                          vertical: AppDimensions.p12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.radius16,
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppDimensions.r10),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: (item.photo != null && item.photo!.isNotEmpty)
                                  ? OtzarCachedImage(
                                      imageUrlOrPath: item.photo!,
                                      width: 38,
                                      height: 38,
                                      fit: BoxFit.cover,
                                      borderRadius: BorderRadius.circular(AppDimensions.r10 - 1),
                                      errorWidget: Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: AppDimensions.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          style: AppTypography.displayMedium.copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.formula.isNotEmpty) ...[
                                        const SizedBox(width: AppDimensions.p6),
                                        Flexible(
                                          child: Text(
                                            item.formula,
                                            style: AppTypography.monoTag.copyWith(
                                              color: AppColors.subtle,
                                              fontSize: 8.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        '${item.conf}%',
                                        style: AppTypography.hudTicker.copyWith(
                                          color: color,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' · ${item.loc} · ${item.date}',
                                          style: AppTypography.hudTicker.copyWith(
                                            color: AppColors.subtle,
                                            fontSize: 9,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.p8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.p6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceBorder,
                                    borderRadius: BorderRadius.circular(AppDimensions.r4),
                                  ),
                                  child: Text(
                                    item.grade,
                                    style: AppTypography.hudTicker.copyWith(
                                      color: AppColors.subtle,
                                      fontSize: 8,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item.synced
                                        ? AppColors.emerald
                                        : AppColors.ember,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}
}
