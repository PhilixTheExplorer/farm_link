import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FarmCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String category;
  final VoidCallback onTap;

  const FarmCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.onTap,
  }) : super(key: key);

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
              padding: const EdgeInsets.all(16.0),
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
                  
                  // Price
                  Text(
                    '฿$price',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.tamarindBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.palmAshGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
