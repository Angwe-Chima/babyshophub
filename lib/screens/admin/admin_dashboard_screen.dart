// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/support_ticket_model.dart';
import 'user_management_screen.dart';
import 'product_management_screen.dart';
import 'order_management_screen.dart';
import 'support_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminProvider, UserProvider>(
      builder: (context, adminProvider, userProvider, child) {
        // Check if user is admin
        if (userProvider.currentUser?.isAdmin != true) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppConstants.primaryColor,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () => adminProvider.refreshAllData(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => adminProvider.refreshAllData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(userProvider.currentUser),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Statistics Cards
                  _buildStatisticsSection(adminProvider.dashboardStats),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Recent Activity
                  _buildRecentActivity(adminProvider.getRecentActivity()),
                  const SizedBox(height: AppConstants.spacingLarge),

                  // Management Sections
                  _buildManagementSections(context, adminProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 30,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user?.firstName ?? 'Admin'}!',
                  style: AppConstants.headingMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your baby shop with ease',
                  style: AppConstants.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppConstants.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                '${stats['totalUsers'] ?? 0}',
                Icons.people,
                AppConstants.primaryColor,
                subtitle: '${stats['activeUsers'] ?? 0} active',
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: _buildStatCard(
                'Products',
                '${stats['totalProducts'] ?? 0}',
                Icons.inventory,
                AppConstants.accentColor,
                subtitle: '${stats['lowStockProducts'] ?? 0} low stock',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Monthly Orders',
                '${stats['monthlyOrders'] ?? 0}',
                Icons.shopping_cart,
                AppConstants.successColor,
                subtitle: 'This month',
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: _buildStatCard(
                'Revenue',
                '\$${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                Icons.monetization_on,
                Colors.purple,
                subtitle: 'This month',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color, {
        String? subtitle,
      }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            value,
            style: AppConstants.headingMedium.copyWith(
              color: AppConstants.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppConstants.bodySmall.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppConstants.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Product',
                Icons.add_box,
                AppConstants.primaryColor,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductManagementScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: _buildActionCard(
                'View Orders',
                Icons.list_alt,
                AppConstants.accentColor,
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderManagementScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              title,
              style: AppConstants.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppConstants.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: activities.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(AppConstants.paddingLarge),
            child: Center(
              child: Text('No recent activity'),
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActivityColor(activity['type']).withOpacity(0.1),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: _getActivityColor(activity['type']),
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'],
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  activity['description'],
                  style: AppConstants.bodySmall,
                ),
                trailing: Text(
                  _formatTimestamp(activity['timestamp']),
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textLight,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManagementSections(BuildContext context, AdminProvider adminProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management',
          style: AppConstants.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.spacingSmall,
          mainAxisSpacing: AppConstants.spacingSmall,
          children: [
            _buildManagementCard(
              'User Management',
              'Manage users and permissions',
              Icons.people_alt,
              AppConstants.primaryColor,
              '${adminProvider.dashboardStats['totalUsers'] ?? 0} users',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementScreen(),
                ),
              ),
            ),
            _buildManagementCard(
              'Product Management',
              'Manage inventory and pricing',
              Icons.inventory_2,
              AppConstants.accentColor,
              '${adminProvider.dashboardStats['totalProducts'] ?? 0} products',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductManagementScreen(),
                ),
              ),
            ),
            _buildManagementCard(
              'Order Management',
              'Track and manage orders',
              Icons.shopping_bag,
              AppConstants.successColor,
              '${adminProvider.dashboardStats['monthlyOrders'] ?? 0} this month',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderManagementScreen(),
                ),
              ),
            ),
            _buildManagementCard(
              'Support Management',
              'Handle user inquiries',
              Icons.support_agent,
              Colors.purple,
              '${adminProvider.dashboardStats['openTickets'] ?? 0} open tickets',
                  () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportManagementScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard(
      String title,
      String description,
      IconData icon,
      Color color,
      String stats,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stats,
              style: AppConstants.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'order':
        return AppConstants.successColor;
      case 'ticket':
        return Colors.purple;
      case 'user':
        return AppConstants.primaryColor;
      default:
        return AppConstants.textSecondary;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'ticket':
        return Icons.support_agent;
      case 'user':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}