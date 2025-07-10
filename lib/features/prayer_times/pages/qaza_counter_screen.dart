import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/prayer/prayer_providers.dart';
import 'package:islamia/data/models/prayer/prayer_log.dart';
import 'package:islamia/data/models/prayer/prayer_tracking.dart';

class QazaCounterScreen extends ConsumerWidget {
  const QazaCounterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qazaCounterAsync = ref.watch(qazaCounterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qaza Counter'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reset All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 8),
                    Text('Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: qazaCounterAsync.when(
        data: (counter) => _buildQazaContent(context, ref, counter),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, ref, error.toString()),
      ),
    );
  }

  Widget _buildQazaContent(
    BuildContext context,
    WidgetRef ref,
    QazaCounter counter,
  ) {
    final prayers = [
      PrayerType.fajr,
      PrayerType.dhuhr,
      PrayerType.asr,
      PrayerType.maghrib,
      PrayerType.isha,
    ];

    return Column(
      children: [
        _buildTotalQazaCard(counter),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prayers.length,
            itemBuilder: (context, index) {
              final prayer = prayers[index];
              final count = counter.missedPrayers[prayer.name] ?? 0;
              return _buildQazaPrayerCard(context, ref, prayer, count);
            },
          ),
        ),
        _buildInfoCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTotalQazaCard(QazaCounter counter) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                size: 48,
                color: Colors.orange[700],
              ),
              const SizedBox(height: 12),
              Text(
                '${counter.totalMissed}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              Text(
                'Total Missed Prayers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (counter.totalMissed > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Last updated: ${_formatDate(counter.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQazaPrayerCard(
    BuildContext context,
    WidgetRef ref,
    PrayerType prayer,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: prayer.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  prayer.icon,
                  color: prayer.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: count > 0
                        ? () => ref.read(qazaCounterProvider.notifier).decrementQaza(prayer)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red[600],
                  ),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: count > 0 ? Colors.orange[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: count > 0 ? Colors.orange[700] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(qazaCounterProvider.notifier).incrementQaza(prayer),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.green[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'About Qaza Prayers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Qaza prayers are missed prayers that need to be made up. It is important to perform them as soon as possible. You can pray Qaza at any time except during the forbidden times.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text('Failed to load Qaza counter'),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(qazaCounterProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'reset_all':
        _showResetAllDialog(context, ref);
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  void _showResetAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Qaza'),
        content: const Text('Are you sure you want to reset all Qaza counters to zero?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(qazaCounterProvider.notifier).resetAllQaza();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All Qaza counters reset')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qaza Prayer Guide'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What are Qaza Prayers?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Qaza prayers are missed obligatory prayers that must be made up. Every Muslim is required to perform the five daily prayers on time.',
              ),
              SizedBox(height: 16),
              Text(
                'When to Perform Qaza:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• As soon as you remember\n'
                '• Before the next prayer time\n'
                '• Any time except forbidden times\n'
                '• Before sleeping if possible',
              ),
              SizedBox(height: 16),
              Text(
                'Forbidden Times:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• When the sun is rising\n'
                '• When the sun is at its zenith\n'
                '• When the sun is setting',
              ),
            ],
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}