// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../config/constants.dart';
import '../../services/user_service.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Female';
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _dobController.text = user.dateOfBirth ?? '';
      _selectedGender = user.gender ?? 'Female';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 8),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppConstants.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        _dobController.text = "${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
      return;
    }

    if (_firstNameController.text.trim().isEmpty) {
      _showSnackBar('First name is required', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (authProvider.user != null) {
        await UserService.updateUserProfile(
          uid: authProvider.user!.uid,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _selectedGender,
        );

        // Refresh user data
        final updatedUser = await UserService.getUser(authProvider.user!.uid);
        if (updatedUser != null) {
          userProvider.setUser(updatedUser);
        }

        _showSnackBar('Profile updated successfully', isError: false);
      }
    } catch (e) {
      _showSnackBar('Failed to update profile: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppConstants.errorColor : AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await authProvider.logout();
      userProvider.clearUser();
    }
  }

  Widget _buildProfileHeader() {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final displayName = user != null ? '${user.firstName} ${user.lastName ?? ''}'.trim() : 'User Name';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.accentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 45,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Edit Profile Button
          ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
            )
                : Text(
              _isEditing ? 'Save Changes' : 'Edit Profile',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing && controller != null)
              TextField(
                controller: controller,
                readOnly: label == 'Email Address' || label == 'Date of Birth',
                onTap: label == 'Date of Birth' ? _selectDate : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.neutralColor.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: label == 'Date of Birth'
                      ? Icon(Icons.calendar_today, size: 18, color: AppConstants.primaryColor)
                      : null,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppConstants.textPrimary,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty
                        ? AppConstants.textSecondary.withOpacity(0.7)
                        : AppConstants.textPrimary,
                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppConstants.neutralColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _selectedGender,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppConstants.textSecondary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Personal Information Section
            _buildSectionTitle('Personal Information'),

            // Info Fields
            _buildInfoField('First Name', _firstNameController.text, controller: _firstNameController),
            _buildInfoField('Last Name', _lastNameController.text, controller: _lastNameController),
            _buildInfoField('Email Address', _emailController.text, controller: _emailController),
            _buildInfoField('Phone Number', _phoneController.text, controller: _phoneController),
            _buildInfoField('Date of Birth', _dobController.text, controller: _dobController),
            _buildGenderField(),

            // Account Actions Section
            _buildSectionTitle('Account Actions'),

            // Action Items
            _buildActionItem('Order History', Icons.history),
            _buildActionItem('Saved Addresses', Icons.location_on),
            _buildActionItem('Payment Methods', Icons.payment),
            _buildActionItem(
              'Support & FAQs',
              Icons.help_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}