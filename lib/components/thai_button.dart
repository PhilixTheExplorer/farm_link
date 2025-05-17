import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ThaiButtonVariant {
  primary,
  secondary,
  accent,
}

class ThaiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ThaiButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const ThaiButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.variant = ThaiButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine button colors based on variant
    Color backgroundColor;
    Color textColor;
    
    switch (variant) {
      case ThaiButtonVariant.primary:
        backgroundColor = AppColors.tamarindBrown;
        textColor = Colors.white;
        break;
      case ThaiButtonVariant.secondary:
        backgroundColor = AppColors.ricePaddyGreen;
        textColor = Colors.white;
        break;
      case ThaiButtonVariant.accent:
        backgroundColor = AppColors.chilliRed;
        textColor = Colors.white;
        break;
    }
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
