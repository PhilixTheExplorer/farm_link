import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FarmCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String category;
  final String? quantity;
  final String? unit;
  final bool showDescription;
  final VoidCallback onTap;

  const FarmCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    this.quantity,
    this.unit,
    this.showDescription = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
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
                    label: Text(category),
                    backgroundColor: AppColors.ricePaddyGreen.withOpacity(0.2),
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
                    title,
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
                          '฿$price',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.tamarindBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (quantity != null && unit != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tamarindBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.tamarindBrown.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$quantity $unit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.tamarindBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Description (conditional)
                  if (showDescription) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.palmAshGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
