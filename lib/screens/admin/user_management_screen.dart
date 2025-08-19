// screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  String _filterRole = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && user.isActive) ||
          (_filterStatus == 'Inactive' && !user.isActive);

      final matchesRole = _filterRole == 'All' ||
          (_filterRole == 'Admin' && user.isAdmin) ||
          (_filterRole == 'User' && !user.isAdmin);

      return matchesSearch && matchesStatus && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AdminProvider>(context, listen: false).loadUsers();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoadingUsers) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: AppConstants.headingMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    adminProvider.error!,
                    style: AppConstants.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredUsers = _getFilteredUsers(adminProvider.users);

          return Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilterSection(),

              // Users List
              Expanded(
                child: filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUsersList(filteredUsers, adminProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // Filter Options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  items: ['All', 'Active', 'Inactive']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                ),
              ),

              const SizedBox(width: AppConstants.spacingSmall),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  items: ['All', 'User', 'Admin']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterRole = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserModel> users, AdminProvider adminProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, adminProvider);
      },
    );
  }

  Widget _buildUserCard(UserModel user, AdminProvider adminProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMedium),
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
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: user.isActive
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : AppConstants.errorColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: user.isActive
                        ? AppConstants.primaryColor
                        : AppConstants.errorColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: AppConstants.spacingMedium),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.fullName,
                            style: AppConstants.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (user.isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ADMIN',
                                style: AppConstants.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      if (user.phone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.phone!,
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppConstants.successColor.withOpacity(0.1)
                        : AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: AppConstants.bodySmall.copyWith(
                      color: user.isActive
                          ? AppConstants.successColor
                          : AppConstants.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // User Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Joined',
                    user.createdAt != null
                        ? _formatDate(user.createdAt!)
                        : 'Unknown',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Interests',
                    '${user.interests.length} selected',
                    Icons.favorite,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Onboarding',
                    user.hasCompletedOnboarding ? 'Complete' : 'Pending',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMedium),
            const Divider(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _showUserDetailsDialog(user),
                  icon: Icon(Icons.info, size: 18, color: AppConstants.primaryColor),
                  label: Text(
                    'Details',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _toggleUserStatus(user, adminProvider),
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 18,
                    color: user.isActive ? AppConstants.errorColor : AppConstants.successColor,
                  ),
                  label: Text(
                    user.isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: user.isActive ? AppConstants.errorColor : AppConstants.successColor,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showRoleDialog(user, adminProvider),
                  icon: Icon(Icons.admin_panel_settings, size: 18, color: AppConstants.accentColor),
                  label: Text(
                    'Role',
                    style: TextStyle(color: AppConstants.accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppConstants.textSecondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppConstants.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppConstants.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: AppConstants.headingMedium.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', user.fullName),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Phone', user.phone ?? 'Not provided'),
              _buildDetailRow('Date of Birth', user.dateOfBirth ?? 'Not provided'),
              _buildDetailRow('Gender', user.gender ?? 'Not provided'),
              _buildDetailRow('Address', user.address ?? 'Not provided'),
              _buildDetailRow('Role', user.isAdmin ? 'Admin' : 'User'),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Onboarding', user.hasCompletedOnboarding ? 'Completed' : 'Pending'),
              _buildDetailRow('Interests', user.interests.isEmpty ? 'None' : user.interests.join(', ')),
              _buildDetailRow('Joined', user.createdAt != null ? _formatDate(user.createdAt!) : 'Unknown'),
              _buildDetailRow('Last Updated', user.updatedAt != null ? _formatDate(user.updatedAt!) : 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppConstants.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(UserModel user, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User' : 'Activate User'),
        content: Text(
          user.isActive
              ? 'Are you sure you want to deactivate ${user.fullName}? They will not be able to access their account.'
              : 'Are you sure you want to activate ${user.fullName}? They will be able to access their account again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await adminProvider.updateUserStatus(user.uid, !user.isActive);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User ${user.isActive ? 'deactivated' : 'activated'} successfully',
                    ),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update user status'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? AppConstants.errorColor : AppConstants.successColor,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(UserModel user, AdminProvider adminProvider) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select role for ${user.fullName}:'),
              const SizedBox(height: 16),
              RadioListTile<UserRole>(
                title: const Text('User'),
                subtitle: const Text('Regular user with standard permissions'),
                value: UserRole.user,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              RadioListTile<UserRole>(
                title: const Text('Admin'),
                subtitle: const Text('Administrator with full permissions'),
                value: UserRole.admin,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedRole == user.role
                  ? null
                  : () async {
                Navigator.of(context).pop();
                final success = await adminProvider.updateUserRole(user.uid, selectedRole);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User role updated successfully'),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update user role'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }}