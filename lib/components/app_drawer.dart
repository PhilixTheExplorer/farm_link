import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Drawer(
      backgroundColor: AppColors.bambooCream,
      child: Column(
        children: [
          // Header with user profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.ricePaddyGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // User Profile Section
                CircleAvatar(
                  radius: 35,
                  backgroundImage:
                      userService.currentUser?.profileImageUrl != null
                          ? NetworkImage(
                            userService.currentUser!.profileImageUrl!,
                          )
                          : null,
                  backgroundColor: AppColors.palmAshGray.withOpacity(0.3),
                  child:
                      userService.currentUser?.profileImageUrl == null
                          ? const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.white,
                          )
                          : null,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userService.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userService.currentUserRole == UserRole.farmer
                          ? 'Farmer'
                          : 'Buyer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildMenuItems(context),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.palmAshGray.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  route: '/about',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  route: '/help',
                  onTap: () => _showHelpDialog(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  route: '/logout',
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.ricePaddyGreen.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              onTap ??
              () {
                context.pop(); // Close drawer
                if (currentRoute != route) {
                  context.go(route);
                }
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.ricePaddyGreen.withOpacity(0.2)
                            : AppColors.palmAshGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? AppColors.ricePaddyGreen
                            : AppColors.palmAshGray,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isSelected
                              ? AppColors.ricePaddyGreen
                              : AppColors.charcoalBlack,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.ricePaddyGreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final userService = UserService();
    List<Widget> menuItems = [];

    // Common items for all users
    menuItems.add(
      _buildDrawerItem(
        context,
        icon: Icons.storefront,
        title: 'Marketplace',
        route: AppRoutes.buyerMarketplace,
      ),
    );

    // Role-specific items
    if (userService.canAccessFarmerDashboard()) {
      menuItems.add(
        _buildDrawerItem(
          context,
          icon: Icons.dashboard,
          title: 'Farmer Dashboard',
          route: AppRoutes.farmerDashboard,
        ),
      );
    }

    if (userService.canAccessCart()) {
      menuItems.add(
        _buildDrawerItem(
          context,
          icon: Icons.shopping_cart,
          title: 'Cart',
          route: AppRoutes.cart,
        ),
      );
    }

    if (userService.canAccessImpactTracker()) {
      menuItems.add(
        _buildDrawerItem(
          context,
          icon: Icons.eco,
          title: 'Impact Tracker',
          route: AppRoutes.impactTracker,
        ),
      );
    }

    // Common items for all users
    menuItems.add(
      _buildDrawerItem(
        context,
        icon: Icons.person,
        title: 'Profile',
        route: AppRoutes.profileSettings,
      ),
    );

    return menuItems;
  }

  void _showAboutDialog(BuildContext context) {
    context.pop(); // Close drawer
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About FarmLink'),
            content: const Text(
              'FarmLink connects local farmers directly with buyers, promoting sustainable agriculture and fair trade practices. '
              'Our platform helps farmers reach more customers while providing buyers with fresh, local produce.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    context.pop(); // Close drawer
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('For assistance, please contact us:'),
                const SizedBox(height: 12),
                Text('📧 Email: support@farmlink.co.th'),
                Text('📞 Phone: +66 2 123 4567'),
                Text('💬 Live Chat: Available 9 AM - 6 PM'),
                const SizedBox(height: 12),
                Text('You can also visit our website for FAQs and tutorials.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    context.pop(); // Close drawer
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
                onPressed: () {
                  context.pop();
                  UserService().logout(); // Clear user data
                  context.go(AppRoutes.login);
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
}
