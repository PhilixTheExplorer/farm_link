import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../theme/app_colors.dart';

class OrderConfirmationView extends StatelessWidget {
  const OrderConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample order data
    final orderData = {
      'orderNumber': 'FL-2023-0042',
      'date': 'May 16, 2023',
      'total': '฿440',
      'items': [
        {
          'title': 'Organic Rice',
          'quantity': 2,
          'price': '฿240',
          'farmer': {
            'name': 'Somchai',
            'location': 'Chiang Mai',
            'phone': '+66 81 234 5678',
            'email': 'somchai@farmlink.com',
          },
        },
        {
          'title': 'Fresh Mangoes',
          'quantity': 3,
          'price': '฿200',
          'farmer': {
            'name': 'Malee',
            'location': 'Chiang Rai',
            'phone': '+66 82 345 6789',
            'email': 'malee@farmlink.com',
          },
        },
      ],
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.ricePaddyGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.ricePaddyGreen,
                        size: 48,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Thank You Message
                    Text(
                      'Thank You!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order has been placed successfully',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Order Summary Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Number',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.palmAshGray,
                                  ),
                                ),
                                Text(
                                  orderData['orderNumber']!.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.palmAshGray,
                                  ),
                                ),
                                Text(
                                  orderData['date']!.toString(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.palmAshGray,
                                  ),
                                ),
                                Text(
                                  orderData['total']!.toString(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.tamarindBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Divider(height: 32),
                            
                            // Order Items
                            Text(
                              'Order Items',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            ...List.generate(
                              (orderData['items'] as List).length,
                              (index) {
                                final item = (orderData['items'] as List)[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Item Quantity
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.ricePaddyGreen.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            item['quantity'].toString(),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: AppColors.ricePaddyGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      
                                      // Item Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['title'],
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'From ${item['farmer']['name']}',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: AppColors.palmAshGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Item Price
                                      Text(
                                        item['price'],
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          color: AppColors.tamarindBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Farmer Contact Information
                    Text(
                      'Farmer Contact Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...List.generate(
                      (orderData['items'] as List).length,
                      (index) {
                        final item = (orderData['items'] as List)[index];
                        final farmer = item['farmer'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Farmer Name and Product
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            farmer['name'],
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'For ${item['title']}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: AppColors.palmAshGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Contact Details
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppColors.palmAshGray,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      farmer['location'],
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: AppColors.palmAshGray,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      farmer['phone'],
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: AppColors.palmAshGray,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      farmer['email'],
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Contact Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.phone),
                                        label: const Text('Call'),
                                        onPressed: () {
                                          // Call farmer
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.tamarindBrown,
                                          side: const BorderSide(color: AppColors.tamarindBrown),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.email),
                                        label: const Text('Email'),
                                        onPressed: () {
                                          // Email farmer
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.tamarindBrown,
                                          side: const BorderSide(color: AppColors.tamarindBrown),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pickup Instructions
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
                                Icons.info_outline,
                                color: AppColors.ricePaddyGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pickup Instructions',
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
                            'Please contact the farmers directly to arrange pickup or delivery of your items. They will be happy to assist you with the details.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bambooCream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('View Orders'),
                      onPressed: () {
                        // Navigate to orders
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tamarindBrown,
                        side: const BorderSide(color: AppColors.tamarindBrown),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ThaiButton(
                      label: 'Continue Shopping',
                      onPressed: () {
                        // Navigate to marketplace
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/buyer-marketplace',
                          (route) => false,
                        );
                      },
                      variant: ThaiButtonVariant.secondary,
                    ),
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
