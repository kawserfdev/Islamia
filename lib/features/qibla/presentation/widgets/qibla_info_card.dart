import 'package:flutter/material.dart';
import 'package:islamia/core/providers/qibla/qibla_providers.dart';
import 'package:islamia/core/services/qibla/qibla_service.dart';

class QiblaInfoCard extends StatelessWidget {
  final QiblaState qiblaState;

  const QiblaInfoCard({
    Key? key,
    required this.qiblaState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.place,
                    title: 'Your Location',
                    value: _getLocationText(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.mosque,
                    title: 'Distance to Kaaba',
                    value: _getDistanceText(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.explore,
                    title: 'Qibla Direction',
                    value: '${qiblaState.qiblaDirection.toInt()}°',
                    subtitle: QiblaService.formatDirection(qiblaState.qiblaDirection),
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.navigation,
                    title: 'Current Heading',
                    value: '${qiblaState.compassHeading.toInt()}°',
                    subtitle: QiblaService.formatDirection(qiblaState.compassHeading),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLocationText() {
    if (qiblaState.userLocation == null) return '--';
    
    final location = qiblaState.userLocation!;
    if (location.city != null && location.country != null) {
      return '${location.city}, ${location.country}';
    }
    
    return '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}';
  }

  String _getDistanceText() {
    if (qiblaState.qibla == null) return '--';
    
    return QiblaService.formatDistance(qiblaState.qibla!.distance);
  }
}