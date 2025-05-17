import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StoryCircle extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isViewed;
  final VoidCallback onTap;

  const StoryCircle({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.isViewed = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isViewed ? AppColors.palmAshGray.withOpacity(0.3) : AppColors.chilliRed,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: AppColors.bambooCream,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Name
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
