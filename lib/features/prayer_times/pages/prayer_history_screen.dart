import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/prayer/prayer_providers.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';
import 'package:islamia/data/models/prayer/prayer_tracking.dart';
import 'package:table_calendar/table_calendar.dart';

class PrayerHistoryScreen extends ConsumerStatefulWidget {
  const PrayerHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrayerHistoryScreen> createState() => _PrayerHistoryScreenState();
}

class _PrayerHistoryScreenState extends ConsumerState<PrayerHistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final trackingForSelectedDay = ref.watch(prayerTrackingProvider(_selectedDay));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer History'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          Expanded(
            child: _buildDayDetails(trackingForSelectedDay),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<PrayerTracking>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) {
        // This would load prayer tracking data for the day
        return [];
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: Colors.green[700],
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.green[400],
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.orange[600],
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildDayDetails(List<PrayerTracking> tracking) {
    final prayers = [
      PrayerType.fajr,
      PrayerType.dhuhr,
      PrayerType.asr,
      PrayerType.maghrib,
      PrayerType.isha,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatSelectedDate(_selectedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: prayers.length,
              itemBuilder: (context, index) {
                final prayer = prayers[index];
                final prayerTracking = tracking.firstWhere(
                  (t) => t.prayerType == prayer,
                  orElse: () => PrayerTracking(
                    id: '',
                    date: _selectedDay,
                    prayerType: prayer,
                  ),
                );

                return _buildPrayerTrackingCard(prayer, prayerTracking);
              },
            ),
          ),
          _buildDayStatistics(tracking),
        ],
      ),
    );
  }

  Widget _buildPrayerTrackingCard(PrayerType prayer, PrayerTracking tracking) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (tracking.isPrayed) {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      statusText = _formatTime(tracking.prayedAt!);
    } else if (tracking.isQaza) {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
      statusText = 'Marked as Qaza';
    } else if (_selectedDay.isBefore(DateTime.now()) && 
               DateTime.now().day != _selectedDay.day) {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
      statusText = 'Missed';
    } else {
      statusIcon = Icons.radio_button_unchecked;
      statusColor = Colors.grey;
      statusText = 'Not prayed yet';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: prayer.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            prayer.icon,
            color: prayer.color,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              prayer.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              prayer.arabicName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Noto Naskh Arabic',
              ),
            ),
          ],
        ),
        subtitle: tracking.note != null && tracking.note!.isNotEmpty
            ? Text(
                'Note: ${tracking.note}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStatistics(List<PrayerTracking> tracking) {
    final totalPrayers = 5;
    final prayedCount = tracking.where((t) => t.isPrayed).length;
    final qazaCount = tracking.where((t) => t.isQaza).length;
    final missedCount = totalPrayers - prayedCount - qazaCount;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Prayed', prayedCount, Colors.green),
                _buildStatItem('Qaza', qazaCount, Colors.orange),
                _buildStatItem('Missed', missedCount, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}