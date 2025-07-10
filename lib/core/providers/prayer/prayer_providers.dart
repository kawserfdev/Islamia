import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamia/core/services/location_service.dart';
import 'package:islamia/core/services/prayer/prayer_api_service.dart';
import 'package:islamia/core/services/prayer/prayer_database_service.dart';
import 'package:islamia/core/services/prayer/prayer_notification_service.dart';
import 'package:islamia/data/models/prayer/prayer_tracking.dart';
import '../../../data/models/prayer/prayer_times_model.dart';

// Service providers
final prayerApiServiceProvider = Provider<PrayerApiService>((ref) {
  return PrayerApiService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final prayerDatabaseServiceProvider = Provider<PrayerDatabaseService>((ref) {
  return PrayerDatabaseService();
});

final prayerNotificationServiceProvider = Provider<PrayerNotificationService>((ref) {
  return PrayerNotificationService();
});

// Current location provider
final currentLocationProvider = FutureProvider<LocationModel>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Prayer settings provider
final prayerSettingsProvider = StateNotifierProvider<PrayerSettingsNotifier, AsyncValue<PrayerSettings>>((ref) {
  return PrayerSettingsNotifier(ref.read(prayerDatabaseServiceProvider));
});

// Today's prayer times provider
final todayPrayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  final apiService = ref.read(prayerApiServiceProvider);
  final dbService = ref.read(prayerDatabaseServiceProvider);
  final locationAsync = ref.watch(currentLocationProvider);
  final settingsAsync = ref.watch(prayerSettingsProvider);
  
  final location = await locationAsync;
  final settings = await settingsAsync.value ?? const PrayerSettings();
  
  try {
    // Try to get from cache first
    final cachedPrayerTimes = await dbService.getCachedPrayerTimes(DateTime.now());
    
    if (cachedPrayerTimes != null && 
        cachedPrayerTimes.location.latitude == location.value?.latitude &&
        cachedPrayerTimes.location.longitude == location.value?.longitude) {
      return cachedPrayerTimes;
    }
    
    // Fetch from API
    final prayerTimes = await apiService.getPrayerTimes(
      latitude: location.value!.latitude,
      longitude: location.value!.longitude,
      method: _getMethodId(settings.calculationMethod),
      madhab: _getMadhabId(settings.madhab),
    );
    
    // Cache the result
    await dbService.cachePrayerTimes(prayerTimes);
    
    return prayerTimes;
  } catch (e) {
    // Fallback to cached data
    final cachedPrayerTimes = await dbService.getCachedPrayerTimes(DateTime.now());
    if (cachedPrayerTimes != null) {
      return cachedPrayerTimes;
    }
    rethrow;
  }
});

// Monthly prayer times provider
final monthlyPrayerTimesProvider = FutureProvider.family<Map<DateTime, PrayerTimesModel>, DateTime>((ref, month) async {
  final apiService = ref.read(prayerApiServiceProvider);
  final dbService = ref.read(prayerDatabaseServiceProvider);
  final locationAsync = ref.watch(currentLocationProvider);
  final settingsAsync = ref.watch(prayerSettingsProvider);
  
  final location = await locationAsync;
  final settings = await settingsAsync.value ?? const PrayerSettings();
  
  try {
    // Try to get from cache first
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final cachedPrayerTimes = await dbService.getCachedPrayerTimesForRange(startOfMonth, endOfMonth);
    
    if (cachedPrayerTimes.length >= endOfMonth.day) {
      return cachedPrayerTimes;
    }
    
    // Fetch from API
    final monthlyPrayerTimes = await apiService.getPrayerTimesForMonth(
      latitude: location.value!.latitude,
      longitude: location.value!.longitude,
      method: _getMethodId(settings.calculationMethod),
      madhab: _getMadhabId(settings.madhab),
      month: month,
    );
    
    // Cache the results
    for (final prayerTimes in monthlyPrayerTimes.values) {
      await dbService.cachePrayerTimes(prayerTimes);
    }
    
    return monthlyPrayerTimes;
  } catch (e) {
    // Fallback to cached data
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    return await dbService.getCachedPrayerTimesForRange(startOfMonth, endOfMonth);
  }
});

// Next prayer provider
final nextPrayerProvider = Provider<(PrayerType?, Duration?)>((ref) {
  final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
  
  return prayerTimesAsync.when(
    data: (prayerTimes) {
      final nextPrayer = prayerTimes.getNextPrayer();
      final timeToNext = prayerTimes.getTimeToNextPrayer();
      return (nextPrayer, timeToNext);
    },
    loading: () => (null, null),
    error: (_, __) => (null, null),
  );
});

// Prayer tracking provider
final prayerTrackingProvider = StateNotifierProvider.family<PrayerTrackingNotifier, List<PrayerTracking>, DateTime>((ref, date) {
  return PrayerTrackingNotifier(ref.read(prayerDatabaseServiceProvider), date);
});

// Qaza counter provider
final qazaCounterProvider = StateNotifierProvider<QazaCounterNotifier, AsyncValue<QazaCounter>>((ref) {
  return QazaCounterNotifier(ref.read(prayerDatabaseServiceProvider));
});

// Qibla direction provider
final qiblaDirectionProvider = FutureProvider<double>((ref) async {
  final locationAsync = ref.watch(currentLocationProvider);
  final location = await locationAsync;
  
  final locationService = ref.read(locationServiceProvider);
  return await locationService.calculateQiblaDirection(
    location.value!.latitude,
    location.value!.longitude,
  );
});

// Helper functions
String _getMethodId(String methodName) {
  switch (methodName) {
    case 'Karachi':
      return '1';
    case 'ISNA':
      return '2';
    case 'MWL':
      return '3';
    case 'Makkah':
      return '4';
    case 'Egypt':
      return '5';
    default:
      return '3'; // MWL
  }
}

String _getMadhabId(String madhabName) {
  switch (madhabName) {
    case 'Hanafi':
      return '1';
    case 'Shafi':
    default:
      return '0';
  }
}

// State Notifiers
class PrayerSettingsNotifier extends StateNotifier<AsyncValue<PrayerSettings>> {
  final PrayerDatabaseService _dbService;

  PrayerSettingsNotifier(this._dbService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _dbService.getPrayerSettings() ?? const PrayerSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(PrayerSettings settings) async {
    try {
      await _dbService.savePrayerSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCalculationMethod(String method) async {
    final currentSettings = state.value ?? const PrayerSettings();
    await updateSettings(currentSettings.copyWith(calculationMethod: method));
  }

  Future<void> updateMadhab(String madhab) async {
    final currentSettings = state.value ?? const PrayerSettings();
    await updateSettings(currentSettings.copyWith(madhab: madhab));
  }

  Future<void> updateNotificationSettings(Map<String, bool> notifications) async {
    final currentSettings = state.value ?? const PrayerSettings();
    await updateSettings(currentSettings.copyWith(prayerNotifications: notifications));
  }
}

class PrayerTrackingNotifier extends StateNotifier<List<PrayerTracking>> {
  final PrayerDatabaseService _dbService;
  final DateTime _date;

  PrayerTrackingNotifier(this._dbService, this._date) : super([]) {
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    final tracking = await _dbService.getPrayerTrackingForDate(_date);
    state = tracking;
  }

Future<void> markPrayerPrayed(PrayerType prayerType, {String? note}) async {
  print('🕋 Marking $prayerType prayed');

  final tracking = PrayerTracking(
    id: '${_date.millisecondsSinceEpoch}_${prayerType.name}',
    date: _date,
    prayerType: prayerType,
    prayedAt: DateTime.now(),
    note: note,
  );

  await _dbService.trackPrayer(tracking);
  await _loadTracking();
}


  Future<void> markPrayerQaza(PrayerType prayerType) async {
    final tracking = PrayerTracking(
      id: '${_date.millisecondsSinceEpoch}_${prayerType.name}',
      date: _date,
      prayerType: prayerType,
      isQaza: true,
    );

    await _dbService.trackPrayer(tracking);
    await _loadTracking();
  }
}

class QazaCounterNotifier extends StateNotifier<AsyncValue<QazaCounter>> {
  final PrayerDatabaseService _dbService;

  QazaCounterNotifier(this._dbService) : super(const AsyncValue.loading()) {
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    try {
      final counter = await _dbService.getQazaCounter();
      state = AsyncValue.data(counter);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> incrementQaza(PrayerType prayerType) async {
    try {
      final currentCounter = state.value ?? QazaCounter(lastUpdated: DateTime.now());
      final updatedMissed = Map<String, int>.from(currentCounter.missedPrayers);
      updatedMissed[prayerType.name] = (updatedMissed[prayerType.name] ?? 0) + 1;

      await _dbService.updateQazaCounter(prayerType.name, updatedMissed[prayerType.name]!);
      
      final newCounter = currentCounter.copyWith(
        missedPrayers: updatedMissed,
        lastUpdated: DateTime.now(),
      );
      
      state = AsyncValue.data(newCounter);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> decrementQaza(PrayerType prayerType) async {
    try {
      final currentCounter = state.value ?? QazaCounter(lastUpdated: DateTime.now());
      final updatedMissed = Map<String, int>.from(currentCounter.missedPrayers);
      final currentCount = updatedMissed[prayerType.name] ?? 0;
      
      if (currentCount > 0) {
        updatedMissed[prayerType.name] = currentCount - 1;
        await _dbService.updateQazaCounter(prayerType.name, updatedMissed[prayerType.name]!);
        
        final newCounter = currentCounter.copyWith(
          missedPrayers: updatedMissed,
          lastUpdated: DateTime.now(),
        );
        
        state = AsyncValue.data(newCounter);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetQaza(PrayerType prayerType) async {
    try {
      await _dbService.updateQazaCounter(prayerType.name, 0);
      await _loadCounter();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetAllQaza() async {
    try {
      for (final prayerType in PrayerType.values) {
        if (prayerType != PrayerType.sunrise && prayerType != PrayerType.tahajjud) {
          await _dbService.updateQazaCounter(prayerType.name, 0);
        }
      }
      await _loadCounter();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}