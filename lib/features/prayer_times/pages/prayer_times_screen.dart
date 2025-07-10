import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/prayer/prayer_providers.dart';
import 'package:islamia/data/models/prayer/prayer_times_model.dart';
import 'package:islamia/data/models/prayer/prayer_tracking.dart';
import 'dart:async';
import 'prayer_settings_screen.dart';
import 'prayer_history_screen.dart';
import 'qaza_counter_screen.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Update countdown every second
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final nextPrayerInfo = ref.watch(nextPrayerProvider);
    final qiblaDirectionAsync = ref.watch(qiblaDirectionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayPrayerTimesProvider);
          ref.invalidate(currentLocationProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildLocationHeader(context),
              const SizedBox(height: 16),
              _buildNextPrayerCard(nextPrayerInfo),
              const SizedBox(height: 16),
              prayerTimesAsync.when(
                data: (prayerTimes) => _buildPrayerTimesList(context, prayerTimes),
                loading: () => _buildLoadingWidget(),
                error: (error, stack) => _buildErrorWidget(context, error.toString()),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context, qiblaDirectionAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    
    return locationAsync.when(
      data: (location) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.city,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      location.country,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(DateTime.now()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Getting location...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400]),
              const SizedBox(width: 8),
              const Expanded(child: Text('Location unavailable')),
              TextButton(
                onPressed: () => ref.invalidate(currentLocationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard((PrayerType?, Duration?) nextPrayerInfo) {
    final (nextPrayer, timeToNext) = nextPrayerInfo;
    
    if (nextPrayer == null || timeToNext == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.nights_stay, size: 48, color: Colors.indigo[300]),
              const SizedBox(height: 8),
              const Text(
                'All prayers completed for today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                'Next Fajr tomorrow',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final progress = _calculateProgress(timeToNext);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(nextPrayer.icon, color: nextPrayer.color, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Next Prayer: ${nextPrayer.displayName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(nextPrayer.color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _formatDuration(timeToNext),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context, PrayerTimesModel prayerTimes) {
    final prayers = prayerTimes.getAllPrayerSchedules()
        .where((p) => p.type != PrayerType.sunrise) // Hide sunrise from main list
        .toList();
    final currentPrayer = prayerTimes.getCurrentPrayer();
    
    return Column(
      children: prayers.map((prayer) {
        final isPast = DateTime.now().isAfter(prayer.time);
        final isCurrent = currentPrayer == prayer.type;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildPrayerCard(
            context,
            prayer,
            isPast: isPast,
            isCurrent: isCurrent,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrayerCard(
    BuildContext context,
    PrayerSchedule prayer, {
    bool isPast = false,
    bool isCurrent = false,
  }) {
    final today = DateTime.now();
    final trackingAsync = ref.watch(prayerTrackingProvider(today));
    
    return Card(
      elevation: isCurrent ? 4 : 1,
      child: Container(
        decoration: isCurrent
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: prayer.type.color, width: 2),
              )
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: prayer.type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              prayer.type.icon,
              color: prayer.type.color,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Text(
                prayer.type.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isPast ? Colors.grey[600] : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                prayer.type.arabicName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Noto Naskh Arabic',
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: prayer.type.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            _formatTime(prayer.time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isPast ? Colors.grey[500] : Colors.grey[700],
            ),
          ),
          trailing: _buildPrayerActions(context, prayer, trackingAsync),
        ),
      ),
    );
  }

  Widget _buildPrayerActions(
    BuildContext context,
    PrayerSchedule prayer,
    List<PrayerTracking> tracking,
  ) {
    final prayerTracking = tracking.firstWhere(
      (t) => t.prayerType == prayer.type,
      orElse: () => PrayerTracking(
        id: '',
        date: DateTime.now(),
        prayerType: prayer.type,
      ),
    );

    if (prayerTracking.isPrayed) {
      return Icon(
        Icons.check_circle,
        color: Colors.green[600],
        size: 24,
      );
    }

    if (prayerTracking.isQaza) {
      return Icon(
        Icons.schedule,
        color: Colors.orange[600],
        size: 24,
      );
    }

    return PopupMenuButton<String>(
      onSelected: (value) => _handlePrayerAction(context, prayer.type, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'mark_prayed',
          child: Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 8),
              Text('Mark as Prayed'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'mark_qaza',
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange),
              SizedBox(width: 8),
              Text('Mark as Qaza'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'set_reminder',
          child: Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 8),
              Text('Set Reminder'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, AsyncValue<double> qiblaDirectionAsync) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () => _navigateToQazaCounter(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.format_list_numbered, size: 32, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'Qaza Counter',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () => _showQiblaDirection(context, qiblaDirectionAsync),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.explore, size: 32, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Qibla Direction',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.access_time, color: Colors.grey[400]),
              ),
              title: Container(
                height: 16,
                width: 100,
                color: Colors.grey[200],
              ),
              subtitle: Container(
                height: 14,
                width: 60,
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load prayer times',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(todayPrayerTimesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  double _calculateProgress(Duration timeToNext) {
    // This is a simplified calculation - you might want to make it more accurate
    final totalMinutesInDay = 24 * 60;
    final minutesRemaining = timeToNext.inMinutes;
    return 1.0 - (minutesRemaining / totalMinutesInDay);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _handlePrayerAction(BuildContext context, PrayerType prayerType, String action) {
    final today = DateTime.now();
    final notifier = ref.read(prayerTrackingProvider(today).notifier);
    
    switch (action) {
      case 'mark_prayed':
        notifier.markPrayerPrayed(prayerType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prayerType.displayName} marked as prayed')),
        );
        break;
      case 'mark_qaza':
        notifier.markPrayerQaza(prayerType);
        ref.read(qazaCounterProvider.notifier).incrementQaza(prayerType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prayerType.displayName} marked as Qaza')),
        );
        break;
      case 'set_reminder':
        _showReminderDialog(context, prayerType);
        break;
    }
  }

  void _showReminderDialog(BuildContext context, PrayerType prayerType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Reminder for ${prayerType.displayName}'),
        content: const Text('Reminder functionality will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }

  void _showQiblaDirection(BuildContext context, AsyncValue<double> qiblaDirectionAsync) {
    qiblaDirectionAsync.when(
      data: (direction) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Qibla Direction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 64, color: Colors.green[700]),
                const SizedBox(height: 16),
                Text(
                  '${direction.round()}°',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Direction to Mecca'),
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
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculating Qibla direction...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate Qibla direction')),
        );
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrayerSettingsScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrayerHistoryScreen()),
    );
  }

  void _navigateToQazaCounter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QazaCounterScreen()),
    );
  }
}