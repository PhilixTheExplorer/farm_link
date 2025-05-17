import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class ImpactTrackerView extends StatelessWidget {
  const ImpactTrackerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample impact data
    final impactData = {
      'totalSpent': 2450,
      'farmersSupported': 5,
      'farmerSharePercent': 90,
      'ordersPlaced': 8,
      'localProducts': 12,
      'carbonSaved': 15, // kg CO2 equivalent
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Impact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.eco,
                    size: 48,
                    color: AppColors.ricePaddyGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Positive Impact',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See how your purchases are making a difference',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.palmAshGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Impact Stats
            Row(
              children: [
                // Total Spent
                Expanded(
                  child: _buildImpactCard(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'Total Spent',
                    value: '฿${impactData['totalSpent']}',
                    subtitle: 'Supporting local economy',
                    color: AppColors.tamarindBrown,
                  ),
                ),
                const SizedBox(width: 16),
                // Farmers Supported
                Expanded(
                  child: _buildImpactCard(
                    context,
                    icon: Icons.people_outline,
                    title: 'Farmers Supported',
                    value: impactData['farmersSupported'].toString(),
                    subtitle: 'Direct connections',
                    color: AppColors.ricePaddyGreen,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Farmer Share Progress
            Text(
              'Farmer Share',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Progress Ring
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(
                            painter: ProgressRingPainter(
                              progress: impactData['farmerSharePercent']! / 100,
                              progressColor: AppColors.ricePaddyGreen,
                              backgroundColor: AppColors.ricePaddyGreen.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                '${impactData['farmerSharePercent']}%',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ricePaddyGreen,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direct to Farmers',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${impactData['farmerSharePercent']}% of your money goes directly to farmers, compared to 15-30% in traditional supply chains.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Additional Impact Stats
            Text(
              'Your Achievements',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Orders Placed
            _buildAchievementCard(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Orders Placed',
              value: impactData['ordersPlaced'].toString(),
              progress: impactData['ordersPlaced']! / 10, // Progress towards 10 orders
              progressColor: AppColors.tamarindBrown,
              nextMilestone: '10 Orders',
            ),
            
            const SizedBox(height: 16),
            
            // Local Products Purchased
            _buildAchievementCard(
              context,
              icon: Icons.location_on_outlined,
              title: 'Local Products',
              value: impactData['localProducts'].toString(),
              progress: impactData['localProducts']! / 20, // Progress towards 20 products
              progressColor: AppColors.chilliRed,
              nextMilestone: '20 Products',
            ),
            
            const SizedBox(height: 16),
            
            // Carbon Footprint Saved
            _buildAchievementCard(
              context,
              icon: Icons.eco_outlined,
              title: 'Carbon Saved',
              value: '${impactData['carbonSaved']} kg',
              progress: impactData['carbonSaved']! / 50, // Progress towards 50 kg
              progressColor: AppColors.ricePaddyGreen,
              nextMilestone: '50 kg CO₂',
            ),
            
            const SizedBox(height: 32),
            
            // Motivational Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.ricePaddyGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.ricePaddyGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.ricePaddyGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'re a Top Supporter!',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.ricePaddyGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re in the top 10% of FarmLink users making a difference for Thai farmers. Keep it up!',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.palmAshGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required double progress,
    required Color progressColor,
    required String nextMilestone,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: progressColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.palmAshGray,
                      ),
                    ),
                    Text(
                      'Next: $nextMilestone',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.palmAshGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: progressColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  
  ProgressRingPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final progressRect = Rect.fromCircle(center: center, radius: radius);
    
    // Start from the top (270 degrees) and go clockwise
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(progressRect, startAngle, sweepAngle, false, progressPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
