import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricLogin = false;
  bool _autoSync = true;

  @override
  void initState() {
    super.initState();
    // initialize from ThemeService
    _darkModeEnabled = ThemeService().themeMode.value == ThemeMode.dark;
    ThemeService().themeMode.addListener(() {
      final isDark = ThemeService().themeMode.value == ThemeMode.dark;
      if (mounted) setState(() => _darkModeEnabled = isDark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: AppStyles.heading2(context),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [
                  _buildSettingSwitch(
                    Iconsax.notification,
                    'Push Notifications',
                    'Receive push notifications',
                    _notificationsEnabled,
                    (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildSettingSwitch(
                    Iconsax.moon,
                    'Dark Mode',
                    'Enable dark theme',
                    _darkModeEnabled,
                    (value) {
                      setState(() {
                        _darkModeEnabled = value;
                        ThemeService().setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      });
                    },
                  ),
                  _buildSettingSwitch(
                    Iconsax.finger_scan,
                    'Biometric Login',
                    'Use fingerprint or face ID',
                    _biometricLogin,
                    (value) {
                      setState(() {
                        _biometricLogin = value;
                      });
                    },
                  ),
                  _buildSettingSwitch(
                    Iconsax.cloud,
                    'Auto Sync',
                    'Automatically sync data',
                    _autoSync,
                    (value) {
                      setState(() {
                        _autoSync = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Data Management',
              style: AppStyles.heading2(context),
            ),
            
            const SizedBox(height: 20),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDataAction(
                  Iconsax.cloud_add,
                  'Backup Data',
                  AppColors.success,
                  () {},
                ),
                _buildDataAction(
                  Iconsax.cloud_remove,
                  'Restore Data',
                  AppColors.info,
                  () {},
                ),
                _buildDataAction(
                  Iconsax.trash,
                  'Clear Cache',
                  AppColors.warning,
                  () {},
                ),
                _buildDataAction(
                  Iconsax.refresh,
                  'Reset Data',
                  AppColors.danger,
                  () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset All Data'),
                        content: const Text(
                          'This will delete all your data. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Reset data
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'About',
              style: AppStyles.heading2(context),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              decoration: AppStyles.cardDecoration(context),
              child: Column(
                children: [

                  _buildAboutItem(
                    Iconsax.info_circle,
                    'About App',
                    'Version 1.0.0 • Product Hub',
                  ),
                  _buildAboutItem(
                    Iconsax.document,
                    'Privacy Policy',
                    'Read our privacy policy',
                  ),
                  _buildAboutItem(
                    Iconsax.note_text,
                    'Terms of Service',
                    'Read our terms and conditions',
                  ),
                  _buildAboutItem(
                    Iconsax.message_question,
                    'Help & Support',
                    'Get help and contact support',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Product Hub',
                    style: AppStyles.heading3(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: AppStyles.body2(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Product Hub All rights reserved.',
                    style: AppStyles.caption(context).copyWith(
                      color: AppColors.grey,
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

  Widget _buildSettingSwitch(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppStyles.subtitle1(context)),
      subtitle: Text(subtitle, style: AppStyles.body2(context)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }

  Widget _buildDataAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppStyles.subtitle2(context).copyWith(
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

  Widget _buildAboutItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppStyles.subtitle1(context)),
      subtitle: Text(subtitle, style: AppStyles.body2(context)),
      trailing: const Icon(Iconsax.arrow_right_3, size: 20),
      onTap: () {},
    );
  }
}