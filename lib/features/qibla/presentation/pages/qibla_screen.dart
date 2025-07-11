import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/providers/qibla/qibla_providers.dart';
import 'package:islamia/data/models/qibla/qibla_model.dart';
import 'package:islamia/features/qibla/presentation/widgets/calibration_guide.dart';
import 'package:islamia/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:islamia/features/qibla/presentation/widgets/qibla_info_card.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(qiblaProvider.notifier).refreshLocation(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'calibrate':
                  ref.read(qiblaProvider.notifier).calibrateCompass();
                  break;
                case 'settings':
                  _showSettingsDialog(context);
                  break;
                case 'help':
                  _showHelpDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'calibrate',
                child: ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Calibrate Compass'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, ref, qiblaState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, QiblaState state) {
    switch (state.status) {
      case CompassState.loading:
        return _buildLoadingState();
      
      case CompassState.noPermission:
        return _buildPermissionState(ref);
      
      case CompassState.noSensor:
        return _buildNoSensorState();
      
      case CompassState.error:
        return _buildErrorState(state.error, ref);
      
      case CompassState.calibrating:
        return _buildCalibratingState();
      
      case CompassState.ready:
        return _buildCompassState(context, state);
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing compass...'),
        ],
      ),
    );
  }

  Widget _buildPermissionState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To determine the Qibla direction, we need access to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.read(qiblaProvider.notifier).requestPermissions(),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSensorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Compass Not Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your device does not have a compass sensor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Compass Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.read(qiblaProvider.notifier).requestPermissions(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibratingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CalibrationGuide(),
        SizedBox(height: 32),
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Calibrating compass...'),
      ],
    );
  }

  Widget _buildCompassState(BuildContext context, QiblaState state) {
    return Column(
      children: [
        // Status indicator
        if (!state.isCalibrated)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, 
                     color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text('Compass needs calibration'),
                const Spacer(),
                TextButton(
                  onPressed: () => _showCalibrationDialog(context),
                  child: const Text('Calibrate'),
                ),
              ],
            ),
          ),
        
        // Info cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: QiblaInfoCard(qiblaState: state),
        ),
        
        // Main compass
        Expanded(
          child: Center(
            child: CompassWidget(
              qiblaDirection: state.qiblaDirection,
              compassHeading: state.compassHeading,
              isPointingToQibla: state.isPointingToQibla,
            ),
          ),
        ),
        
        // Direction indicator
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDirectionInfo(
                    'Current Direction',
                    QiblaService.formatDirection(state.compassHeading),
                    '${state.compassHeading.toInt()}°',
                  ),
                  _buildDirectionInfo(
                    'Qibla Direction',
                    QiblaService.formatDirection(state.qiblaDirection),
                    '${state.qiblaDirection.toInt()}°',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.isPointingToQibla)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, 
                           color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Pointing towards Qibla',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionInfo(String label, String direction, String degrees) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          direction,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          degrees,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compass Calibration'),
        content: const CalibrationGuide(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    // Implementation for settings dialog
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Hold your device flat like a traditional compass'),
              SizedBox(height: 8),
              Text('2. Make sure location services are enabled'),
              SizedBox(height: 8),
              Text('3. Calibrate the compass if prompted'),
              SizedBox(height: 8),
              Text('4. Turn your body until the needle points to the Kaaba icon'),
              SizedBox(height: 8),
              Text('5. You are now facing the Qibla direction'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
