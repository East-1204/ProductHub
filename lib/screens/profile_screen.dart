import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'login_screen.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Admin User');
  final _emailController = TextEditingController(text: 'admin@example.com');
  final _phoneController = TextEditingController(text: '+6281234567890');
  final _addressController = TextEditingController(
    text: 'Jl. Sudirman No. 123, Jakarta',
  );
  
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Iconsax.close_circle : Iconsax.edit,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Container(
              decoration: AppStyles.cardDecoration(context),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.profile_circle,
                          size: 80,
                          color: AppColors.white,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Iconsax.camera,
                              size: 20,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _nameController.text,
                    style: AppStyles.heading2(context),
                  ),
                  
                  Text(
                    _emailController.text,
                    style: AppStyles.body2(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('Products', '24'),
                      _buildStatItem('Sales', '128'),
                      _buildStatItem('Reviews', '4.8'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Information
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Iconsax.user, color: AppColors.primary),
                    title: Text(
                      'Personal Information',
                      style: AppStyles.subtitle1(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Divider(height: 0),
                  
                  // Editable Fields
                  _buildEditableField('Full Name', _nameController, Iconsax.user),
                  _buildEditableField('Email', _emailController, Iconsax.sms),
                  _buildEditableField('Phone', _phoneController, Iconsax.call),
                  _buildEditableField('Address', _addressController, Iconsax.location),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Options
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [

                  _buildOptionItem(
                    Iconsax.notification,
                    'Notifications',
                    'Manage your notifications',
                  ),
                  _buildOptionItem(
                    Iconsax.security,
                    'Privacy & Security',
                    'Control your privacy settings',
                  ),
                  _buildOptionItem(
                    Iconsax.setting,
                    'App Settings',
                    'Customize app preferences',
                  ),
                  _buildOptionItem(
                    Iconsax.info_circle,
                    'About App',
                    'Version 1.0.0 • Product Hub',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger.withAlpha((0.1 * 255).round()),
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Iconsax.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppStyles.heading3(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: AppStyles.caption(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppStyles.caption(context).copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.text,
                        style: AppStyles.body1(context),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppStyles.subtitle1(context)),
      subtitle: Text(subtitle, style: AppStyles.body2(context)),
      trailing: const Icon(Iconsax.arrow_right_3, size: 20),
      onTap: () {},
    );
  }
}