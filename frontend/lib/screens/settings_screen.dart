import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'vi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      _SectionHeader(
                        icon: Icons.person_rounded,
                        title: 'Account',
                      ),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.edit_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Change your profile information',
                            color: Colors.blue,
                            onTap: () {
                              _showComingSoon(context, 'Edit Profile');
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.lock_rounded,
                            title: 'Change Password',
                            subtitle: 'Update your password',
                            color: Colors.orange,
                            onTap: () {
                              _showComingSoon(context, 'Change Password');
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.privacy_tip_rounded,
                            title: 'Privacy',
                            subtitle: 'Manage your privacy settings',
                            color: Colors.purple,
                            onTap: () {
                              _showComingSoon(context, 'Privacy Settings');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Notifications Section
                      _SectionHeader(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                      ),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsSwitchTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Push Notifications',
                            subtitle: 'Receive push notifications',
                            color: Colors.green,
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsSwitchTile(
                            icon: Icons.email_rounded,
                            title: 'Email Notifications',
                            subtitle: 'Receive notifications via email',
                            color: Colors.blue,
                            value: _emailNotifications,
                            onChanged: (value) {
                              setState(() {
                                _emailNotifications = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Appearance Section
                      _SectionHeader(
                        icon: Icons.palette_rounded,
                        title: 'Appearance',
                      ),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsSwitchTile(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: 'Enable dark theme',
                            color: Colors.indigo,
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dark mode will be available soon!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: _selectedLanguage == 'vi' ? 'Tiếng Việt' : 'English',
                            color: Colors.teal,
                            trailing: DropdownButton<String>(
                              value: _selectedLanguage,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'vi',
                                  child: Text('🇻🇳 Tiếng Việt'),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('🇬🇧 English'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguage = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Support Section
                      _SectionHeader(
                        icon: Icons.help_rounded,
                        title: 'Support',
                      ),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.help_center_rounded,
                            title: 'Help Center',
                            subtitle: 'Get help and support',
                            color: Colors.cyan,
                            onTap: () {
                              _showComingSoon(context, 'Help Center');
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.feedback_rounded,
                            title: 'Send Feedback',
                            subtitle: 'Share your thoughts with us',
                            color: Colors.pink,
                            onTap: () {
                              _showComingSoon(context, 'Send Feedback');
                            },
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.info_rounded,
                            title: 'About',
                            subtitle: 'App version and information',
                            color: Colors.grey,
                            onTap: () {
                              _showAboutDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Danger Zone
                      _SectionHeader(
                        icon: Icons.warning_rounded,
                        title: 'Danger Zone',
                      ),
                      const SizedBox(height: 12),
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.delete_forever_rounded,
                            title: 'Delete Account',
                            subtitle: 'Permanently delete your account',
                            color: Colors.red,
                            onTap: () {
                              _showDeleteAccountDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Portal App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A modern job portal application built with Flutter.',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}