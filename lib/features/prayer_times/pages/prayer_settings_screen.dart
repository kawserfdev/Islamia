import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/prayer/prayer_providers.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';
class PrayerSettingsScreen extends ConsumerWidget {
  const PrayerSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(prayerSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Settings'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionCard(
          'Calculation Method',
          [
            _buildCalculationMethodTile(context, ref, settings),
            _buildMadhabTile(context, ref, settings),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          'Notifications',
          [
            _buildNotificationToggle(ref, settings),
            ...PrayerType.values
                .where((type) => type != PrayerType.sunrise)
                .map((type) => _buildPrayerNotificationTile(ref, settings, type)),
            _buildReminderMinutesTile(context,ref, settings),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          'Audio Settings',
          [
            _buildAdhanToggle(ref, settings),
            _buildAdhanSoundTile(context, ref, settings),
            _buildAdhanVolumeTile(ref, settings),
            _buildVibrationToggle(ref, settings),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          'Location',
          [
            _buildLocationAutoUpdateTile(ref, settings),
            _buildManualLocationTile(context, ref, settings),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          'Advanced',
          [
            _buildAdjustmentsTile(context, ref, settings),
            _buildResetSettingsTile(context, ref),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children.map((child) => Column(
            children: [
              child,
              if (child != children.last) const Divider(height: 1),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCalculationMethodTile(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListTile(
      title: const Text('Calculation Method'),
      subtitle: Text(settings.calculationMethod),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCalculationMethodDialog(context, ref, settings),
    );
  }

  Widget _buildMadhabTile(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListTile(
      title: const Text('Madhab (Asr Calculation)'),
      subtitle: Text(settings.madhab),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showMadhabDialog(context, ref, settings),
    );
  }

  Widget _buildNotificationToggle(WidgetRef ref, PrayerSettings settings) {
    return SwitchListTile(
      title: const Text('Prayer Notifications'),
      subtitle: const Text('Enable prayer time notifications'),
      value: settings.notificationsEnabled,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(notificationsEnabled: value);
        ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildPrayerNotificationTile(
    WidgetRef ref,
    PrayerSettings settings,
    PrayerType prayerType,
  ) {
    return SwitchListTile(
      title: Text('${prayerType.displayName} Notification'),
      value: settings.prayerNotifications[prayerType.name] ?? true,
      onChanged: settings.notificationsEnabled
          ? (value) {
              final updatedNotifications = Map<String, bool>.from(settings.prayerNotifications);
              updatedNotifications[prayerType.name] = value;
              final updatedSettings = settings.copyWith(prayerNotifications: updatedNotifications);
              ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
            }
          : null,
    );
  }

  Widget _buildReminderMinutesTile(BuildContext context, WidgetRef ref, PrayerSettings settings) {
    return ListTile(
      title: const Text('Reminder Before Prayer'),
      subtitle: Text('${settings.reminderMinutes} minutes before'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showReminderMinutesDialog(context, ref, settings),
    );
  }

  Widget _buildAdhanToggle(WidgetRef ref, PrayerSettings settings) {
    return SwitchListTile(
      title: const Text('Adhan Audio'),
      subtitle: const Text('Play Adhan for prayer notifications'),
      value: settings.adhanEnabled,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(adhanEnabled: value);
        ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildAdhanSoundTile(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListTile(
      title: const Text('Adhan Sound'),
      subtitle: Text(_getAdhanSoundName(settings.adhanSound)),
      trailing: const Icon(Icons.chevron_right),
      enabled: settings.adhanEnabled,
      onTap: settings.adhanEnabled
             ? () => _showAdhanSoundDialog(context, ref, settings)
          : null,
    );
  }

  Widget _buildAdhanVolumeTile(WidgetRef ref, PrayerSettings settings) {
    return ListTile(
      title: const Text('Adhan Volume'),
      subtitle: Slider(
        value: settings.adhanVolume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: '${(settings.adhanVolume * 100).round()}%',
        onChanged: settings.adhanEnabled
            ? (value) {
                final updatedSettings = settings.copyWith(adhanVolume: value);
                ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
              }
            : null,
      ),
      trailing: Text('${(settings.adhanVolume * 100).round()}%'),
    );
  }

  Widget _buildVibrationToggle(WidgetRef ref, PrayerSettings settings) {
    return SwitchListTile(
      title: const Text('Vibration'),
      subtitle: const Text('Vibrate for prayer notifications'),
      value: settings.vibrationEnabled,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(vibrationEnabled: value);
        ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildLocationAutoUpdateTile(WidgetRef ref, PrayerSettings settings) {
    return SwitchListTile(
      title: const Text('Auto-Update Location'),
      subtitle: const Text('Automatically detect location changes'),
      value: settings.locationAutoUpdate,
      onChanged: (value) {
        final updatedSettings = settings.copyWith(locationAutoUpdate: value);
        ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
      },
    );
  }

  Widget _buildManualLocationTile(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListTile(
      title: const Text('Manual Location'),
      subtitle: Text(
        settings.manualLocation != null
            ? '${settings.manualLocation!.city}, ${settings.manualLocation!.country}'
            : 'Not set',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showManualLocationDialog(context, ref, settings),
    );
  }

  Widget _buildAdjustmentsTile(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    return ListTile(
      title: const Text('Prayer Time Adjustments'),
      subtitle: const Text('Fine-tune prayer times'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAdjustmentsDialog(context, ref, settings),
    );
  }

  Widget _buildResetSettingsTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Reset to Defaults'),
      subtitle: const Text('Reset all settings to default values'),
      trailing: const Icon(Icons.refresh),
      onTap: () => _showResetDialog(context, ref),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text('Failed to load settings'),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(prayerSettingsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showCalculationMethodDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final methods = [
      'University of Islamic Sciences, Karachi',
      'Islamic Society of North America (ISNA)',
      'Muslim World League (MWL)',
      'Umm al-Qura, Makkah',
      'Egyptian General Authority of Survey',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation Method'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              //final isSelected = settings.calculationMethod == method;
              
              return RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: settings.calculationMethod,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(prayerSettingsProvider.notifier).updateCalculationMethod(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMadhabDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final madhabs = ['Shafi', 'Hanafi'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Madhab'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: madhabs.map((madhab) {
            return RadioListTile<String>(
              title: Text(madhab),
              subtitle: Text(_getMadhabDescription(madhab)),
              value: madhab,
              groupValue: settings.madhab,
              onChanged: (value) {
                if (value != null) {
                  ref.read(prayerSettingsProvider.notifier).updateMadhab(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReminderMinutesDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final reminderOptions = [0, 5, 10, 15, 30];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Before Prayer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reminderOptions.map((minutes) {
            return RadioListTile<int>(
              title: Text(minutes == 0 ? 'At prayer time' : '$minutes minutes before'),
              value: minutes,
              groupValue: settings.reminderMinutes,
              onChanged: (value) {
                if (value != null) {
                  final updatedSettings = settings.copyWith(reminderMinutes: value);
                  ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAdhanSoundDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final adhanSounds = [
      {'id': 'default', 'name': 'Default Adhan'},
      {'id': 'makkah', 'name': 'Makkah Adhan'},
      {'id': 'madinah', 'name': 'Madinah Adhan'},
      {'id': 'egypt', 'name': 'Egyptian Adhan'},
      {'id': 'turkey', 'name': 'Turkish Adhan'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adhan Sound'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: adhanSounds.length,
            itemBuilder: (context, index) {
              final sound = adhanSounds[index];
              
              return ListTile(
                title: Text(sound['name']!),
                leading: Radio<String>(
                  value: sound['id']!,
                  groupValue: settings.adhanSound,
                  onChanged: (value) {
                    if (value != null) {
                      final updatedSettings = settings.copyWith(adhanSound: value);
                      ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
                      Navigator.pop(context);
                    }
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    // Play preview of adhan sound
                    ref.read(prayerNotificationServiceProvider).playAdhan(
                      sound['id']!,
                      settings.adhanVolume,
                    );
                  },
                ),
                onTap: () {
                  final updatedSettings = settings.copyWith(adhanSound: sound['id']!);
                  ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showManualLocationDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final cityController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    if (settings.manualLocation != null) {
      cityController.text = settings.manualLocation!.city;
      latController.text = settings.manualLocation!.latitude.toString();
      lngController.text = settings.manualLocation!.longitude.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'Enter city name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Enter latitude',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Enter longitude',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);
              
              if (lat != null && lng != null && cityController.text.isNotEmpty) {
                final location = LocationModel(
                  latitude: lat,
                  longitude: lng,
                  city: cityController.text,
                  country: 'Manual',
                  timezone: DateTime.now().timeZoneName,
                );
                
                final updatedSettings = settings.copyWith(manualLocation: location);
                ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentsDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerSettings settings,
  ) {
    final adjustments = Map<String, int>.from(settings.adjustments);
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Prayer Time Adjustments'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: prayers.map((prayer) {
                final adjustment = adjustments[prayer] ?? 0;
                
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prayer.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('${adjustment > 0 ? '+' : ''}$adjustment min'),
                      ],
                    ),
                    Slider(
                      value: adjustment.toDouble(),
                      min: -30,
                      max: 30,
                      divisions: 12,
                      label: '${adjustment > 0 ? '+' : ''}$adjustment min',
                      onChanged: (value) {
                        setState(() {
                          adjustments[prayer] = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedSettings = settings.copyWith(adjustments: adjustments);
                ref.read(prayerSettingsProvider.notifier).updateSettings(updatedSettings);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(prayerSettingsProvider.notifier).updateSettings(const PrayerSettings());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getAdhanSoundName(String soundId) {
    switch (soundId) {
      case 'default':
        return 'Default Adhan';
      case 'makkah':
        return 'Makkah Adhan';
      case 'madinah':
        return 'Madinah Adhan';
      case 'egypt':
        return 'Egyptian Adhan';
      case 'turkey':
        return 'Turkish Adhan';
      default:
        return 'Default Adhan';
    }
  }

  String _getMadhabDescription(String madhab) {
    switch (madhab) {
      case 'Shafi':
        return 'Asr when shadow = object length';
      case 'Hanafi':
        return 'Asr when shadow = 2x object length';
      default:
        return '';
    }
  }
}