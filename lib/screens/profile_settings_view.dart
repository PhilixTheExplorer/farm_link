import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../viewmodels/profile_settings_viewmodel.dart';
import '../models/user.dart';

class ProfileSettingsView extends ConsumerStatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  ConsumerState<ProfileSettingsView> createState() =>
      _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends ConsumerState<ProfileSettingsView> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileSettingsViewModelProvider.notifier).refreshUser();
    });
  }

  void _toggleLanguage() {
    ref.read(profileSettingsViewModelProvider.notifier).toggleLanguage();

    final state = ref.read(profileSettingsViewModelProvider);
    // Show language change notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isEnglish
              ? 'Language set to English'
              : 'ภาษาถูกตั้งเป็นภาษาไทย',
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
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  context.pop();
                  await ref
                      .read(profileSettingsViewModelProvider.notifier)
                      .logout();
                  if (mounted) {
                    // Navigate to login screen
                    context.go(AppRoutes.login);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.chilliRed,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(profileSettingsViewModelProvider);

    // Listen for errors
    ref.listen<ProfileSettingsState>(profileSettingsViewModelProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.chilliRed,
          ),
        );
        ref.read(profileSettingsViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      drawer: AppDrawer(currentRoute: AppRoutes.profileSettings),
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body:
          state.isLoggingOut
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Logging out...'),
                  ],
                ),
              )
              : SingleChildScrollView(
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
                                state.profileImageUrl != null
                                    ? NetworkImage(state.profileImageUrl!)
                                    : null,
                            backgroundColor: AppColors.ricePaddyGreen,
                            child:
                                state.profileImageUrl == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.userName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            state.roleDisplayName,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Account Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await context.push('/profile-edit');
                            if (result == true && mounted) {
                              // Refresh data when returning from profile edit
                              ref
                                  .read(
                                    profileSettingsViewModelProvider.notifier,
                                  )
                                  .refreshUser();
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ricePaddyGreen,
                          ),
                        ),
                      ],
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
                              value: state.userEmail,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: state.userPhone,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: state.userLocation,
                            ),
                            if (state.userRole == UserRole.buyer &&
                                state.buyerData?.deliveryAddress != null)
                              const Divider(height: 24),
                            if (state.userRole == UserRole.buyer &&
                                state.buyerData?.deliveryAddress != null)
                              _buildInfoRow(
                                context,
                                icon: Icons.home_outlined,
                                label: 'Delivery Address',
                                value: state.deliveryAddress,
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
                          state.userRole == UserRole.farmer
                              ? 'Farm Details'
                              : 'Buyer Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            if (state.userRole == UserRole.farmer) {
                              context.push('/profile-edit').then((result) {
                                if (result == true && mounted) {
                                  ref
                                      .read(
                                        profileSettingsViewModelProvider
                                            .notifier,
                                      )
                                      .refreshUser();
                                }
                              });
                            } else {
                              context.push(
                                '/orders',
                              ); // Navigate to orders for buyers
                            }
                          },
                          icon: Icon(
                            state.userRole == UserRole.farmer
                                ? Icons.edit
                                : Icons.list_alt,
                            size: 16,
                          ),
                          label: Text(
                            state.userRole == UserRole.farmer
                                ? 'Edit'
                                : 'View Orders',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.tamarindBrown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Role-specific content
                    if (state.userRole == UserRole.farmer &&
                        state.farmerData != null)
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
                                value: state.farmName,
                              ),
                              if (state.farmAddress != null) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  context,
                                  icon: Icons.location_on_outlined,
                                  label: 'Farm Address',
                                  value: state.farmAddress!,
                                ),
                              ],
                              if (state.farmDescription != null) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  context,
                                  icon: Icons.description_outlined,
                                  label: 'Description',
                                  value: state.farmDescription!,
                                ),
                              ],
                              const Divider(height: 24),
                              _buildInfoRow(
                                context,
                                icon: Icons.verified_outlined,
                                label: 'Verification Status',
                                value:
                                    state.isVerified
                                        ? 'Verified'
                                        : 'Pending Verification',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                context,
                                icon: Icons.shopping_cart_outlined,
                                label: 'Total Sales',
                                value: '${state.totalSales}',
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (state.userRole == UserRole.buyer &&
                        state.buyerData != null)
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
                                value: '${state.totalOrders}',
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                context,
                                icon: Icons.attach_money_outlined,
                                label: 'Total Spent',
                                value:
                                    '฿${state.totalSpent.toStringAsFixed(2)}',
                              ),
                              if (state.preferences.isNotEmpty) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  context,
                                  icon: Icons.payment_outlined,
                                  label: 'Payment Preferences',
                                  value: state.preferences.join(', '),
                                ),
                              ],
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
                            subtitle: Text(
                              state.isEnglish ? 'English' : 'ไทย (Thai)',
                            ),
                            secondary: const Icon(Icons.language),
                            value: state.isEnglish,
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
