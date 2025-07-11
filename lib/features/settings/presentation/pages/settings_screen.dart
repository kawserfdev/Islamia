import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: userSettings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Account Settings
                SettingsSection(
                  title: 'Account',
                  children: [
                    SettingsTile(
                      title: 'Profile Information',
                      subtitle: 'Edit your personal information',
                      leading: Icons.person,
                      onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                    ),
                    SettingsTile(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      leading: Icons.lock,
                      onTap: () => Navigator.pushNamed(context, '/change-password'),
                    ),
                    SettingsTile(
                      title: 'Email Settings',
                      subtitle: 'Update email and verification',
                      leading: Icons.email,
                      onTap: () => Navigator.pushNamed(context, '/email-settings'),
                    ),
                  ],
                ),

                // Appearance Settings
                SettingsSection(
                  title: 'Appearance',
                  children: [
                    SettingsTile(
                      title: 'Language',
                      subtitle: _getLanguageDisplayName(userSettings.language),
                      leading: Icons.language,
                      onTap: () => _showLanguageDialog(context, ref, userSettings.language),
                    ),
                    SettingsTile(
                      title: 'Theme',
                      subtitle: _getThemeDisplayName(userSettings.theme),
                      leading: Icons.palette,
                      onTap: () => _showThemeDialog(context, ref, userSettings.theme),
                    ),
                    SettingsTile(
                      title: 'Font Size',
                      subtitle: '${userSettings.display.fontSize.toInt()}pt',
                      leading: Icons.text_fields,
                      onTap: () => _showFontSizeDialog(context, ref, userSettings.display),
                    ),
                    SettingsTile(
                      title: 'Display Options',
                      subtitle: 'Arabic text, translations, colors',
                      leading: Icons.display_settings,
                      onTap: () => Navigator.pushNamed(context, '/display-settings'),
                    ),
                  ],
                ),

                // Prayer & Islamic Settings
                SettingsSection(
                  title: 'Prayer & Islamic',
                  children: [
                    SettingsTile(
                      title: 'Prayer Settings',
                      subtitle: 'Calculation method, madhab, adjustments',
                      leading: Icons.access_time,
                      onTap: () => Navigator.pushNamed(context, '/prayer-settings'),
                    ),
                    SettingsTile(
                      title: 'Qibla Settings',
                      subtitle: 'Compass calibration and location',
                      leading: Icons.explore,
                      onTap: () => Navigator.pushNamed(context, '/qibla-settings'),
                    ),
                    SettingsTile(
                      title: 'Audio Settings',
                      subtitle: 'Reciter: ${_getReciterDisplayName(userSettings.audio.defaultReciter)}',
                      leading: Icons.volume_up,
                      onTap: () => Navigator.pushNamed(context, '/audio-settings'),
                    ),
                  ],
                ),

                // Notifications
                SettingsSection(
                  title: 'Notifications',
                  children: [
                    SettingsTile(
                      title: 'Prayer Reminders',
                      subtitle: userSettings.notifications.prayerReminders 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.notifications,
                      trailing: Switch(
                        value: userSettings.notifications.prayerReminders,
                        onChanged: (value) => _updatePrayerReminders(ref, value),
                      ),
                    ),
                    SettingsTile(
                      title: 'Adhan',
                      subtitle: userSettings.notifications.adhanEnabled 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.mosque,
                      trailing: Switch(
                        value: userSettings.notifications.adhanEnabled,
                        onChanged: (value) => _updateAdhanEnabled(ref, value),
                      ),
                    ),
                    SettingsTile(
                      title: 'Islamic Events',
                      subtitle: userSettings.notifications.islamicEvents 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.event,
                      trailing: Switch(
                        value: userSettings.notifications.islamicEvents,
                        onChanged: (value) => _updateIslamicEvents(ref, value),
                      ),
                    ),
                    SettingsTile(
                      title: 'Notification Settings',
                      subtitle: 'Customize all notification preferences',
                      leading: Icons.tune,
                      onTap: () => Navigator.pushNamed(context, '/notification-settings'),
                    ),
                  ],
                ),

                // Privacy & Security
                SettingsSection(
                  title: 'Privacy & Security',
                  children: [
                    SettingsTile(
                      title: 'Privacy Settings',
                      subtitle: 'Control your data and visibility',
                      leading: Icons.privacy_tip,
                      onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
                    ),
                    SettingsTile(
                      title: 'Location Services',
                      subtitle: userSettings.location.enableLocationServices 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.location_on,
                      onTap: () => Navigator.pushNamed(context, '/location-settings'),
                    ),
                    SettingsTile(
                      title: 'Biometric Authentication',
                      subtitle: 'Use fingerprint or face unlock',
                      leading: Icons.fingerprint,
                      onTap: () => _showBiometricDialog(context),
                    ),
                  ],
                ),

                // Data Management
                SettingsSection(
                  title: 'Data Management',
                  children: [
                    SettingsTile(
                      title: 'Backup & Restore',
                      subtitle: 'Manage your data backups',
                      leading: Icons.backup,
                      onTap: () => Navigator.pushNamed(context, '/backup-settings'),
                    ),
                    SettingsTile(
                      title: 'Sync Settings',
                      subtitle: 'Control data synchronization',
                      leading: Icons.sync,
                      onTap: () => Navigator.pushNamed(context, '/sync-settings'),
                    ),
                    SettingsTile(
                      title: 'Export Data',
                      subtitle: 'Download your personal data',
                      leading: Icons.download,
                      onTap: () => _showExportDialog(context, ref),
                    ),
                    SettingsTile(
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      leading: Icons.storage,
                      onTap: () => _showClearCacheDialog(context),
                    ),
                  ],
                ),

                // Accessibility
                SettingsSection(
                  title: 'Accessibility',
                  children: [
                    SettingsTile(
                      title: 'Screen Reader Support',
                      subtitle: userSettings.accessibility.screenReader 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.accessibility,
                      trailing: Switch(
                        value: userSettings.accessibility.screenReader,
                        onChanged: (value) => _updateScreenReader(ref, value),
                      ),
                    ),
                    SettingsTile(
                      title: 'High Contrast',
                      subtitle: userSettings.accessibility.highContrast 
                          ? 'Enabled' : 'Disabled',
                      leading: Icons.contrast,
                      trailing: Switch(
                        value: userSettings.accessibility.highContrast,
                        onChanged: (value) => _updateHighContrast(ref, value),
                      ),
                    ),
                    SettingsTile(
                      title: 'Accessibility Settings',
                      subtitle: 'More accessibility options',
                      leading: Icons.settings_accessibility,
                      onTap: () => Navigator.pushNamed(context, '/accessibility-settings'),
                    ),
                  ],
                ),

                // About & Support
                SettingsSection(
                  title: 'About & Support',
                  children: [
                    SettingsTile(
                      title: 'Help & FAQ',
                      subtitle: 'Get help and support',
                      leading: Icons.help,
                      onTap: () => Navigator.pushNamed(context, '/help'),
                    ),
                    SettingsTile(
                      title: 'Contact Support',
                      subtitle: 'Get in touch with our team',
                      leading: Icons.support_agent,
                      onTap: () => Navigator.pushNamed(context, '/contact-support'),
                    ),
                    SettingsTile(
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      leading: Icons.policy,
                      onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                    ),
                    SettingsTile(
                      title: 'Terms of Service',
                      subtitle: 'Read our terms of service',
                      leading: Icons.description,
                      onTap: () => Navigator.pushNamed(context, '/terms-service'),
                    ),
                    SettingsTile(
                      title: 'About Islamia',
                      subtitle: 'Version 1.0.0',
                      leading: Icons.info,
                      onTap: () => Navigator.pushNamed(context, '/about'),
                    ),
                  ],
                ),

                // Danger Zone
                SettingsSection(
                  title: 'Account Actions',
                  children: [
                    SettingsTile(
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      leading: Icons.logout,
                      titleColor: theme.colorScheme.error,
                      onTap: () => _showSignOutDialog(context, ref),
                    ),
                    SettingsTile(
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      leading: Icons.delete_forever,
                      titleColor: theme.colorScheme.error,
                      onTap: () => _showDeleteAccountDialog(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  // Helper methods for display names
  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'bn':
        return 'বাংলা';
      case 'ur':
        return 'اردو';
      case 'id':
        return 'Bahasa Indonesia';
      case 'tr':
        return 'Türkçe';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'auto':
        return 'Auto (System)';
      default:
        return 'Auto (System)';
    }
  }

  String _getReciterDisplayName(String reciter) {
    switch (reciter) {
      case 'ar.alafasy':
        return 'Mishary Rashid Alafasy';
      case 'ar.husary':
        return 'Mahmoud Khalil Al-Hussary';
      case 'ar.sudais':
        return 'Abdurrahman As-Sudais';
      case 'ar.shuraym':
        return 'Saud Ash-Shuraym';
      default:
        return 'Default Reciter';
    }
  }

  // Dialog methods
  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLanguage) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'bn', 'name': 'বাংলা'},
      {'code': 'ur', 'name': 'اردو'},
      {'code': 'id', 'name': 'Bahasa Indonesia'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'fr', 'name': 'Français'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang['name']!),
              value: lang['code']!,
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userSettingsProvider.notifier).updateLanguage(value);
                  Navigator.pop(context);
                  // Show restart dialog
                  _showRestartDialog(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, String currentTheme) {
    final themes = [
      {'value': 'light', 'name': 'Light'},
      {'value': 'dark', 'name': 'Dark'},
      {'value': 'auto', 'name': 'Auto (System)'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme['name']!),
              value: theme['value']!,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userSettingsProvider.notifier).updateTheme(value);
                  ref.read(themeProvider.notifier).updateTheme(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref, DisplayPreferences display) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            double fontSize = display.fontSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sample text with current size',
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: '${fontSize.toInt()}pt',
                  onChanged: (value) {
                    setState(() => fontSize = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final updatedDisplay = display.copyWith(fontSize: fontSize);
                        ref.read(userSettingsProvider.notifier)
                            .updateDisplayPreferences(updatedDisplay);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showBiometricDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text(
          'Enable biometric authentication to secure your app with fingerprint or face unlock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement biometric setup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric setup coming soon!')),
              );
            },
            child: const Text('Set Up'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Export all your personal data including prayer logs, reading progress, and achievements?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement data export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started!')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and cached data to free up storage space. Your personal data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/delete-account');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Language Changed'),
        content: const Text(
          'The app language has been changed. Please restart the app for changes to take effect.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // You might want to implement app restart logic here
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Settings update methods
  void _updatePrayerReminders(WidgetRef ref, bool value) {
    final currentSettings = ref.read(userSettingsProvider);
    if (currentSettings != null) {
      final updatedNotifications = currentSettings.notifications.copyWith(
        prayerReminders: value,
      );
      ref.read(userSettingsProvider.notifier)
          .updateNotificationPreferences(updatedNotifications);
    }
  }

  void _updateAdhanEnabled(WidgetRef ref, bool value) {
    final currentSettings = ref.read(userSettingsProvider);
    if (currentSettings != null) {
      final updatedNotifications = currentSettings.notifications.copyWith(
        adhanEnabled: value,
      );
      ref.read(userSettingsProvider.notifier)
          .updateNotificationPreferences(updatedNotifications);
    }
  }

  void _updateIslamicEvents(WidgetRef ref, bool value) {
    final currentSettings = ref.read(userSettingsProvider);
    if (currentSettings != null) {
      final updatedNotifications = currentSettings.notifications.copyWith(
        islamicEvents: value,
      );
      ref.read(userSettingsProvider.notifier)
          .updateNotificationPreferences(updatedNotifications);
    }
  }

  void _updateScreenReader(WidgetRef ref, bool value) {
    final currentSettings = ref.read(userSettingsProvider);
    if (currentSettings != null) {
      final updatedAccessibility = currentSettings.accessibility.copyWith(
        screenReader: value,
      );
      ref.read(userSettingsProvider.notifier)
          .updateAccessibilityPreferences(updatedAccessibility);
    }
  }

  void _updateHighContrast(WidgetRef ref, bool value) {
    final currentSettings = ref.read(userSettingsProvider);
    if (currentSettings != null) {
      final updatedAccessibility = currentSettings.accessibility.copyWith(
        highContrast: value,
      );
      ref.read(userSettingsProvider.notifier)
          .updateAccessibilityPreferences(updatedAccessibility);
    }
  }
}