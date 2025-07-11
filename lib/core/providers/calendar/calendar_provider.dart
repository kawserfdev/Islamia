import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hijri_service.dart';
import '../services/islamic_events_service.dart';
import '../models/calendar/hijri_date.dart';
import '../models/calendar/islamic_event.dart';
import '../models/calendar/daily_reminder.dart';

// Services
final hijriServiceProvider = Provider<HijriService>((ref) => HijriService());
final islamicEventsServiceProvider = Provider<IslamicEventsService>((ref) => IslamicEventsService());

// Current date providers
final currentGregorianDateProvider = Provider<DateTime>((ref) => DateTime.now());
final currentHijriDateProvider = FutureProvider<HijriDate>((ref) async {
  final service = ref.read(hijriServiceProvider);
  return await service.getCurrentHijriDate();
});

// Selected date state
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Hijri date for selected date
final selectedHijriDateProvider = FutureProvider<HijriDate>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final service = ref.read(hijriServiceProvider);
  return await service.gregorianToHijri(selectedDate);
});

// Events for selected date
final eventsForDateProvider = FutureProvider<List<IslamicEvent>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getEventsForDate(selectedDate);
});

// Events for current month
final eventsForMonthProvider = FutureProvider.family<List<IslamicEvent>, DateTime>((ref, date) async {
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getEventsForMonth(date.year, date.month);
});

// Daily reminder
final dailyReminderProvider = FutureProvider<DailyReminder>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getDailyReminder(selectedDate);
});

// Calendar view state
final calendarViewProvider = StateProvider<CalendarView>((ref) => CalendarView.month);

// Calendar display mode (Gregorian, Hijri, or Both)
final calendarDisplayModeProvider = StateProvider<CalendarDisplayMode>((ref) => CalendarDisplayMode.both);

// Islamic month info
final islamicMonthInfoProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, monthNumber) async {
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getIslamicMonthInfo(monthNumber);
});

// User events
final userEventsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getUserEvents(userId);
});

// User events for date
final userEventsForDateProvider = FutureProvider.family<List<Map<String, dynamic>>, UserEventsRequest>((ref, request) async {
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getUserEventsForDate(request.userId, request.date);
});

// Event search
final eventSearchProvider = FutureProvider.family<List<IslamicEvent>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.read(islamicEventsServiceProvider);
  return await service.searchEvents(query);
});

// Events by category
final eventsByCategoryProvider = FutureProvider.family<List<IslamicEvent>, IslamicEventCategory>((ref, category) async {
  final service = ref.read(islamicEventsServiceProvider);
  return await service.getEventsByCategory(category);
});

// Calendar state notifier for complex state management
final calendarStateProvider = StateNotifierProvider<CalendarStateNotifier, CalendarState>((ref) {
  return CalendarStateNotifier(
    ref.read(hijriServiceProvider),
    ref.read(islamicEventsServiceProvider),
  );
});

class CalendarState {
  final DateTime selectedDate;
  final CalendarView view;
  final CalendarDisplayMode displayMode;
  final bool isLoading;
  final String? error;
  final List<IslamicEvent> events;
  final HijriDate? hijriDate;
  final DailyReminder? dailyReminder;

  const CalendarState({
    required this.selectedDate,
    this.view = CalendarView.month,
    this.displayMode = CalendarDisplayMode.both,
    this.isLoading = false,
    this.error,
    this.events = const [],
    this.hijriDate,
    this.dailyReminder,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    CalendarView? view,
    CalendarDisplayMode? displayMode,
    bool? isLoading,
    String? error,
    List<IslamicEvent>? events,
    HijriDate? hijriDate,
    DailyReminder? dailyReminder,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      view: view ?? this.view,
      displayMode: displayMode ?? this.displayMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      events: events ?? this.events,
      hijriDate: hijriDate ?? this.hijriDate,
      dailyReminder: dailyReminder ?? this.dailyReminder,
    );
  }
}

class CalendarStateNotifier extends StateNotifier<CalendarState> {
  final HijriService _hijriService;
  final IslamicEventsService _eventsService;

  CalendarStateNotifier(this._hijriService, this._eventsService)
      : super(CalendarState(selectedDate: DateTime.now())) {
    _loadDateData();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date, isLoading: true);
    await _loadDateData();
  }

  Future<void> changeView(CalendarView view) async {
    state = state.copyWith(view: view);
  }

  Future<void> changeDisplayMode(CalendarDisplayMode mode) async {
    state = state.copyWith(displayMode: mode);
  }

  Future<void> _loadDateData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load data in parallel
      final futures = await Future.wait([
        _hijriService.gregorianToHijri(state.selectedDate),
        _eventsService.getEventsForDate(state.selectedDate),
        _eventsService.getDailyReminder(state.selectedDate),
      ]);

      state = state.copyWith(
        hijriDate: futures[0] as HijriDate,
        events: futures[1] as List<IslamicEvent>,
        dailyReminder: futures[2] as DailyReminder,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadDateData();
  }

  Future<void> goToToday() async {
    await selectDate(DateTime.now());
  }

  Future<void> goToPreviousMonth() async {
    final previousMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month - 1,
      1,
    );
    await selectDate(previousMonth);
  }

  Future<void> goToNextMonth() async {
    final nextMonth = DateTime(
      state.selectedDate.year,
      state.selectedDate.month + 1,
      1,
    );
    await selectDate(nextMonth);
  }
}

// Supporting classes
class UserEventsRequest {
  final String userId;
  final DateTime date;

  const UserEventsRequest({
    required this.userId,
    required this.date,
  });
}

enum CalendarView {
  month,
  week,
  day,
  agenda,
}

enum CalendarDisplayMode {
  gregorian,
  hijri,
  both,
}