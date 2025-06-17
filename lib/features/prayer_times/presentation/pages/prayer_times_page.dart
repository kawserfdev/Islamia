import 'package:flutter/material.dart';

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  final List<String> prayerNames = const [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha'
  ];
  final List<String> prayerTimes = const [
    '05:00 AM',
    '01:00 PM',
    '04:30 PM',
    '07:00 PM',
    '08:30 PM'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
      ),
      body: ListView.builder(
        itemCount: prayerNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(prayerNames[index]),
            trailing: Text(prayerTimes[index]),
          );
        },
      ),
    );
  }
}
