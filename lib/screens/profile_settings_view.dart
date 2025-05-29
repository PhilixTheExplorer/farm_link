import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../components/app_drawer.dart';
import '../theme/app_colors.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  bool _isEnglish = true;

  // Sample user data
  final Map<String, dynamic> _userData = {
    'email': 'user@example.com',
    'role': 'Buyer',
    'name': 'John Doe',
    'phone': '+66 81 234 5678',
    'location': 'Bangkok',
    'joinDate': 'May 2023',
  };

  // Sample orders
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'FL-2023-0042',
      'date': 'May 16, 2023',
      'total': '฿440',
      'status': 'Completed',
    },
    {
      'id': 'FL-2023-0036',
      'date': 'May 10, 2023',
      'total': '฿320',
      'status': 'Completed',
    },
    {
      'id': 'FL-2023-0028',
      'date': 'May 3, 2023',
      'total': '฿180',
      'status': 'Completed',
    },
  ];

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
    });

    // Show language change notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEnglish ? 'Language set to English' : 'ภาษาถูกตั้งเป็นภาษาไทย',
        ),
        backgroundColor: AppColors.ricePaddyGreen,
      ),
    );
  }

  void _logout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to login screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.chilliRed,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(currentRoute: '/profile-settings'),
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData['name'],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _userData['role'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.ricePaddyGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Account Information
            Text(
              'Account Information',
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
                    _buildInfoRow(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _userData['email'],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: _userData['phone'],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: _userData['location'],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Joined',
                      value: _userData['joinDate'],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // My Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all orders
                  },
                  child: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tamarindBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['id'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order['total'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.tamarindBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['date'],
                              style: theme.textTheme.bodyMedium,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ricePaddyGreen.withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order['status'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.ricePaddyGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // View order details
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Settings
            Text(
              'Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  // Language Toggle
                  SwitchListTile(
                    title: const Text('Language'),
                    subtitle: Text(_isEnglish ? 'English' : 'ไทย (Thai)'),
                    secondary: const Icon(Icons.language),
                    value: _isEnglish,
                    onChanged: (value) => _toggleLanguage(),
                    activeColor: AppColors.ricePaddyGreen,
                  ),

                  const Divider(height: 1),

                  // Notifications
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notification Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to notification settings
                    },
                  ),

                  const Divider(height: 1),

                  // Privacy Policy
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Show privacy policy
                    },
                  ),

                  const Divider(height: 1),

                  // Terms of Service
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Show terms of service
                    },
                  ),

                  const Divider(height: 1),

                  // About
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About FarmLink'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Show about
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            ThaiButton(
              label: 'Logout',
              onPressed: _logout,
              variant: ThaiButtonVariant.accent,
              icon: Icons.logout,
              isFullWidth: true,
            ),

            const SizedBox(height: 32),

            // App Version
            Center(
              child: Text(
                'FarmLink v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.palmAshGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.palmAshGray),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.palmAshGray,
              ),
            ),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
