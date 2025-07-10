import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/qibla/qibla_service.dart';
import 'package:islamia/data/models/qibla/qibla_model.dart';
final qiblaProvider = StateNotifierProvider<QiblaNotifier, QiblaState>(
  (ref) => QiblaNotifier(),
);

class QiblaState {
  final CompassState status;
  final QiblaModel? qibla;
  final double compassHeading;
  final double qiblaDirection;
  final bool isCalibrated;
  final String? error;
  final Location? userLocation;

  const QiblaState({
    this.status = CompassState.loading,
    this.qibla,
    this.compassHeading = 0.0,
    this.qiblaDirection = 0.0,
    this.isCalibrated = false,
    this.error,
    this.userLocation,
  });

  QiblaState copyWith({
    CompassState? status,
    QiblaModel? qibla,
    double? compassHeading,
    double? qiblaDirection,
    bool? isCalibrated,
    String? error,
    Location? userLocation,
  }) {
    return QiblaState(
      status: status ?? this.status,
      qibla: qibla ?? this.qibla,
      compassHeading: compassHeading ?? this.compassHeading,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      error: error ?? this.error,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  // Calculate the angle difference between compass and Qibla
  double get angleDifference {
    if (qibla == null) return 0.0;
    
    double diff = qibla!.direction - compassHeading;
    
    // Normalize to -180 to 180 range
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;
    
    return diff;
  }

  // Check if pointing towards Qibla (within tolerance)
  bool get isPointingToQibla {
    const double tolerance = 5.0; // 5 degrees tolerance
    return angleDifference.abs() <= tolerance;
  }
}

class QiblaNotifier extends StateNotifier<QiblaState> {
  StreamSubscription<double>? _compassSubscription;
  Timer? _calibrationTimer;

  QiblaNotifier() : super(const QiblaState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(status: CompassState.loading);

      // Check compass availability
      final isAvailable = await QiblaService.isCompassAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          status: CompassState.noSensor,
          error: 'Compass sensor not available',
        );
        return;
      }

      // Get user location
      final location = await QiblaService.getCurrentLocation();
      
      // Calculate Qibla direction
      final qibla = QiblaService.calculateQiblaDirection(location);

      state = state.copyWith(
        userLocation: location,
        qibla: qibla,
        qiblaDirection: qibla.direction,
      );

      // Start compass stream
      _startCompassStream();

    } catch (e) {
      String errorMessage = 'Unknown error';
      CompassState errorStatus = CompassState.error;

      if (e is LocationPermissionDeniedException || 
          e is LocationPermissionPermanentlyDeniedException) {
        errorMessage = 'Location permission required';
        errorStatus = CompassState.noPermission;
      } else if (e is LocationServiceDisabledException) {
        errorMessage = 'Please enable location services';
        errorStatus = CompassState.error;
      } else {
        errorMessage = e.toString();
      }

      state = state.copyWith(
        status: errorStatus,
        error: errorMessage,
      );
    }
  }

  void _startCompassStream() {
    final compassStream = QiblaService.getCompassStream();
    
    if (compassStream != null) {
      _compassSubscription = compassStream.listen(
        (heading) {
          state = state.copyWith(
            compassHeading: heading,
            status: CompassState.ready,
            isCalibrated: true,
          );
        },
        onError: (error) {
          state = state.copyWith(
            status: CompassState.error,
            error: 'Compass error: $error',
          );
        },
      );

      // Start calibration process
      _startCalibration();
    }
  }

  void _startCalibration() {
    state = state.copyWith(status: CompassState.calibrating);
    
    _calibrationTimer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(
        status: CompassState.ready,
        isCalibrated: true,
      );
    });
  }

  // Refresh location and recalculate Qibla
  Future<void> refreshLocation() async {
    try {
      state = state.copyWith(status: CompassState.loading);
      
      final location = await QiblaService.getCurrentLocation();
      final qibla = QiblaService.calculateQiblaDirection(location);

      state = state.copyWith(
        userLocation: location,
        qibla: qibla,
        qiblaDirection: qibla.direction,
        status: CompassState.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: CompassState.error,
        error: 'Failed to refresh location: $e',
      );
    }
  }

  // Request permissions
  Future<void> requestPermissions() async {
    await _initialize();
  }

  // Calibrate compass
  void calibrateCompass() {
    _startCalibration();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _calibrationTimer?.cancel();
    super.dispose();
  }
}

// Additional providers for specific data
final qiblaDirectionProvider = Provider<double>((ref) {
  final qiblaState = ref.watch(qiblaProvider);
  return qiblaState.qibla?.direction ?? 0.0;
});

final distanceToKaabaProvider = Provider<String>((ref) {
  final qiblaState = ref.watch(qiblaProvider);
  if (qiblaState.qibla == null) return '--';
  
  return QiblaService.formatDistance(qiblaState.qibla!.distance);
});

final compassHeadingProvider = Provider<double>((ref) {
  final qiblaState = ref.watch(qiblaProvider);
  return qiblaState.compassHeading;
});

final isPointingToQiblaProvider = Provider<bool>((ref) {
  final qiblaState = ref.watch(qiblaProvider);
  return qiblaState.isPointingToQibla;
});