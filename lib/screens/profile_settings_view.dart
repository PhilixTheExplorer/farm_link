import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../components/app_drawer.dart';
import '../theme/app_colors.dart';
import '../core/user_service.dart';
import '../models/user.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  bool _isEnglish = true;
  final UserService _userService = UserService();

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

  void _toggleUserRole() {
    final userService = UserService();
    final currentRole = userService.currentUserRole;
    final newRole =
        currentRole == UserRole.farmer ? UserRole.buyer : UserRole.farmer;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Switch Role'),
            content: Text(
              'Switch from ${currentRole == UserRole.farmer ? 'Farmer' : 'Buyer'} to ${newRole == UserRole.farmer ? 'Farmer' : 'Buyer'}?\n\nThis will change your available features and navigation options.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  userService.switchUserRole(newRole);
                  setState(() {}); // Refresh the UI

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Switched to ${newRole == UserRole.farmer ? 'Farmer' : 'Buyer'} mode',
                      ),
                      backgroundColor: AppColors.ricePaddyGreen,
                    ),
                  );
                },
                child: const Text('Switch'),
              ),
            ],
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _userService.currentUser?.profileImageUrl != null
                            ? NetworkImage(
                              _userService.currentUser!.profileImageUrl!,
                            )
                            : null,
                    child:
                        _userService.currentUser?.profileImageUrl == null
                            ? Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                    backgroundColor: AppColors.ricePaddyGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userService.currentUser?.name ?? 'User',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _userService.currentUserRole == UserRole.farmer
                        ? 'Farmer'
                        : 'Buyer',
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
                      value: _userService.currentUser?.email ?? 'Not set',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: _userService.currentUser?.phone ?? 'Not set',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: _userService.currentUser?.location ?? 'Not set',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Joined',
                      value:
                          _userService.currentUser?.joinDate != null
                              ? '${_userService.currentUser!.joinDate.month}/${_userService.currentUser!.joinDate.year}'
                              : 'Unknown',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Role-specific Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _userService.currentUserRole == UserRole.farmer
                      ? 'Farm Details'
                      : 'My Orders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to detailed view
                  },
                  child: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tamarindBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Role-specific content
            if (_userService.currentUserRole == UserRole.farmer &&
                _userService.farmerData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.agriculture_outlined,
                        label: 'Farm Name',
                        value: _userService.farmerData!.farmName,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.landscape_outlined,
                        label: 'Farm Size',
                        value: '${_userService.farmerData!.farmSize} acres',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.eco_outlined,
                        label: 'Crops',
                        value: _userService.farmerData!.cropTypes.join(', '),
                      ),
                    ],
                  ),
                ),
              )
            else if (_userService.currentUserRole == UserRole.buyer &&
                _userService.buyerData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.shopping_bag_outlined,
                        label: 'Total Orders',
                        value: '${_userService.buyerData!.totalOrders}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.attach_money_outlined,
                        label: 'Total Spent',
                        value:
                            '฿${_userService.buyerData!.totalSpent.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.favorite_outline,
                        label: 'Dietary Preferences',
                        value: _userService.buyerData!.dietaryPreferences.join(
                          ', ',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No additional information available.'),
                ),
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

                  // Role Switcher (For Demo)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('Switch Role'),
                    subtitle: Text(
                      'Current: ${UserService().currentUserRole == UserRole.farmer ? 'Farmer' : 'Buyer'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _toggleUserRole,
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
