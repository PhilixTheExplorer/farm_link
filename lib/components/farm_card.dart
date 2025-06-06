import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/product.dart';

class FarmCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool showFarmerActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FarmCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showFarmerActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.palmAshGray.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Chip
                      Chip(
                        label: Text(product.categoryDisplayName),
                        backgroundColor: AppColors.ricePaddyGreen.withOpacity(
                          0.2,
                        ),
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.ricePaddyGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        product.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Price and quantity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              '฿${product.price}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.tamarindBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (product.quantity > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.tamarindBrown.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.tamarindBrown.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${product.quantity} ${product.unit}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.tamarindBrown,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Farmer Actions (Edit & Delete)
            if (showFarmerActions)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.tamarindBrown,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete,
                            size: 18,
                            color: AppColors.chilliRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
