// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:islamia/data/models/qibla/qibla_model.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:vibration/vibration.dart';
// import 'qibla_calculation_service.dart';

// class QiblaSensorService {
//   static final QiblaSensorService _instance = QiblaSensorService._internal();
//   factory QiblaSensorService() => _instance;
//   QiblaSensorService._internal();

//   StreamController<CompassReading>? _compassController;
//   StreamController<QiblaData>? _qiblaController;
//   StreamSubscription<CompassEvent>? _compassSubscription;
//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

//   final List<double> _compassReadings = [];
//   final List<double> _accelerometerReadings = [];
//   final int _maxReadings = 10;

//   bool _isCalibrated = false;
//   LocationInfo? _currentLocation;
//   QiblaData? _lastQiblaData;

//   Stream<CompassReading> get compassStream {
//     _compassController ??= StreamController<CompassReading>.broadcast();
//     return _compassController!.stream;
//   }

//   Stream<QiblaData> get qiblaStream {
//     _qiblaController ??= StreamController<QiblaData>.broadcast();
//     return _qiblaController!.stream;
//   }

//   Future<bool> initialize() async {
//     try {
//       // Check if compass is available
//       final isAvailable = await FlutterCompass.events?.first != null;
//       if (!isAvailable) {
//         throw QiblaSensorException('Compass sensor not available');
//       }

//       await _startCompassListening();
//       await _startAccelerometerListening();
      
//       return true;
//     } catch (e) {
//       throw QiblaSensorException('Failed to initialize sensors: $e');
//     }
//   }

//   Future<void> _startCompassListening() async {
//     _compassSubscription?.cancel();
    
//     _compassSubscription = FlutterCompass.events?.listen(
//       (CompassEvent event) {
//         if (event.heading != null) {
//           _processCompassReading(event);
//         }
//       },
//       onError: (error) {
//         _handleSensorError('Compass error: $error');
//       },
//     );
//   }

//   Future<void> _startAccelerometerListening() async {
//     _accelerometerSubscription?.cancel();
    
//     _accelerometerSubscription = accelerometerEvents.listen(
//       (AccelerometerEvent event) {
//         _processAccelerometerReading(event);
//       },
//       onError: (error) {
//         _handleSensorError('Accelerometer error: $error');
//       },
//     );
//   }

//   void _processCompassReading(CompassEvent event) {
//     final heading = event.heading!;
//     final accuracy = event.accuracy ?? 0.0;

//     // Add to readings buffer
//     _compassReadings.add(heading);
//     if (_compassReadings.length > _maxReadings) {
//       _compassReadings.removeAt(0);
//     }

//     // Calculate smoothed heading
//     final smoothedHeading = QiblaCalculationService.smoothCompassReading(_compassReadings);
    
//     // Apply magnetic declination if location is available
//     double correctedHeading = smoothedHeading;
//     if (_currentLocation != null) {
//       correctedHeading = QiblaCalculationService.applyMagneticDeclination(
//         smoothedHeading,
//         _currentLocation!.latitude,
//         _currentLocation!.longitude,
//       );
//     }

//     // Calculate accuracy
//     final calculatedAccuracy = QiblaCalculationService.calculateAccuracy(_compassReadings);
    
//     // Determine sensor status
//     final status = _determineSensorStatus(accuracy, calculatedAccuracy);

//     final compassReading = CompassReading(
//       heading: correctedHeading,
//       accuracy: calculatedAccuracy,
//       timestamp: DateTime.now(),
//       status: status,
//     );

//     _compassController?.add(compassReading);

//     // Calculate Qibla if location is available
//     if (_currentLocation != null) {
//       _calculateAndEmitQibla(correctedHeading);
//     }
//   }

//   void _processAccelerometerReading(AccelerometerEvent event) {
//     // Calculate device tilt
//     final tilt = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
//     _accelerometerReadings.add(tilt);
//     if (_accelerometerReadings.length > _maxReadings) {
//       _accelerometerReadings.removeAt(0);
//     }

//     // Check if device is stable (low tilt variance)
//     if (_accelerometerReadings.length >= 5) {
//       final variance = QiblaCalculationService.calculateAccuracy(_accelerometerReadings);
//       _isCalibrated = variance < 2.0; // Device is relatively stable
//     }
//   }

//   void _calculateAndEmitQibla(double compassHeading) {
//     if (_currentLocation == null) return;

//     final calculatedQibla = QiblaCalculationService.calculateQiblaData(_currentLocation!);
    
//     // Adjust for compass heading
//     final adjustedDirection = (calculatedQibla.direction - compassHeading + 360) % 360;
    
//     final qiblaData = calculatedQibla.copyWith(
//       direction: adjustedDirection,
//       source: QiblaSource.sensor,
//     );

//     _lastQiblaData = qiblaData;
//     _qiblaController?.add(qiblaData);

//     // Trigger vibration when pointing towards Qibla
//     _checkQiblaAlignment(adjustedDirection);
//   }

//   void _checkQiblaAlignment(double direction) {
//     const tolerance = 5.0; // 5 degrees tolerance
    
//     if (QiblaCalculationService.isWithinTolerance(direction, 0, tolerance)) {
//       _triggerAlignmentVibration();
//     }
//   }

//   Future<void> _triggerAlignmentVibration() async {
//     if (await Vibration.hasVibrator() ?? false) {
//       await Vibration.vibrate(duration: 100);
//     }
//   }

//   SensorStatus _determineSensorStatus(double? rawAccuracy, double calculatedAccuracy) {
//     if (!_isCalibrated) {
//       return SensorStatus.calibrating;
//     }

//     if (rawAccuracy == null || calculatedAccuracy > 30) {
//       return SensorStatus.error;
//     }

//     if (calculatedAccuracy > 15) {
//       return SensorStatus.unavailable;
//     }

//     return SensorStatus.available;
//   }

//   void _handleSensorError(String error) {
//     final errorReading = CompassReading(
//       heading: 0.0,
//       accuracy: double.infinity,
//       timestamp: DateTime.now(),
//       status: SensorStatus.error,
//     );
    
//     _compassController?.add(errorReading);
//   }

//   Future<void> updateLocation(LocationInfo location) async {
//     _currentLocation = location;
    
//     // Calculate static Qibla data
//     final qiblaData = QiblaCalculationService.calculateQiblaData(location);
//     _qiblaController?.add(qiblaData);
//   }

//   Future<void> calibrateCompass() async {
//     // Reset readings to force recalibration
//     _compassReadings.clear();
//     _accelerometerReadings.clear();
//     _isCalibrated = false;
//   }

//   QiblaData? getLastQiblaData() {
//     return _lastQiblaData;
//   }

//   bool get isCalibrated => _isCalibrated;

//   void dispose() {
//     _compassSubscription?.cancel();
//     _accelerometerSubscription?.cancel();
//     _compassController?.close();
//     _qiblaController?.close();
    
//     _compassController = null;
//     _qiblaController = null;
//     _compassSubscription = null;
//     _accelerometerSubscription = null;
//   }
// }

// class QiblaSensorException implements Exception {
//   final String message;
  
//   QiblaSensorException(this.message);
  
//   @override
//   String toString() => 'QiblaSensorException: $message';
// }