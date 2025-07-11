// Placeholder for islamic_calendar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Islamic Calendar'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const CalendarHeader(),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'today',
                    child: ListTile(
                      leading: Icon(Icons.today),
                      title: Text('Go to Today'),
                      dense: true,
                    ),
                  ),
                   const PopupMenuItem(
                    value: 'view_mode',
                    child: ListTile(
                      leading: Icon(Icons.view_module),
                      title: Text('Change View'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'display_mode',
                    child: ListTile(
                      leading: Icon(Icons.calendar_month),
                      title: Text('Display Mode'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'search',
                    child: ListTile(
                      leading: Icon(Icons.search),
                      title: Text('Search Events'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Export Calendar'),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Hijri Date Display
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: const HijriDateWidget(),
            ),
          ),

          // Calendar Widget
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildCalendarWidget(calendarState),
            ),
          ),

          // Islamic Month Info
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: const IslamicMonthInfo(),
            ),
          ),

          // Daily Reminder
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const DailyReminderCard(),
            ),
          ),

          // Events Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Events',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showAllEvents(),
                    icon: const Icon(Icons.list),
                    label: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

          // Events List
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EventList(),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: const CalendarFAB(),
    );
  }

  Widget _buildCalendarWidget(CalendarState calendarState) {
    return Consumer(
      builder: (context, ref, child) {
        final eventsForMonth = ref.watch(eventsForMonthProvider(calendarState.selectedDate));
        
        return eventsForMonth.when(
          data: (events) => TableCalendar<IslamicEvent>(
            firstDay: DateTime.utc(1900, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: calendarState.selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, calendarState.selectedDate),
            eventLoader: (day) => events.where((event) => 
              isSameDay(event.gregorianDate, day)).toList(),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              ref.read(calendarStateProvider.notifier).selectDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              ref.read(calendarStateProvider.notifier).selectDate(focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getEventColor(events.first as IslamicEvent),
                        shape: BoxShape.circle,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  );
                }
                return null;
              },
              dowBuilder: (context, day) {
                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Center(
                  child: Text(
                    dayNames[(day.weekday - 1) % 7],
                    style: TextStyle(
                      color: day.weekday == DateTime.friday 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: day.weekday == DateTime.friday 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading calendar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEventColor(IslamicEvent event) {
    switch (event.category) {
      case IslamicEventCategory.ramadan:
        return Colors.green;
      case IslamicEventCategory.eid:
        return Colors.red;
      case IslamicEventCategory.hajj:
        return Colors.brown;
      case IslamicEventCategory.prophet:
        return Colors.blue;
      case IslamicEventCategory.sunnah_days:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    final notifier = ref.read(calendarStateProvider.notifier);
    
    switch (action) {
      case 'today':
        notifier.goToToday();
        break;
      case 'view_mode':
        _showViewModeDialog();
        break;
      case 'display_mode':
        _showDisplayModeDialog();
        break;
      case 'search':
        _showSearchDialog();
        break;
      case 'export':
        _exportCalendar();
        break;
    }
  }

  void _showViewModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar View'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CalendarView.values.map((view) {
            return RadioListTile<CalendarView>(
              title: Text(_getViewName(view)),
              value: view,
              groupValue: ref.read(calendarStateProvider).view,
              onChanged: (value) {
                if (value != null) {
                  ref.read(calendarStateProvider.notifier).changeView(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDisplayModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Display Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CalendarDisplayMode.values.map((mode) {
            return RadioListTile<CalendarDisplayMode>(
              title: Text(_getDisplayModeName(mode)),
              subtitle: Text(_getDisplayModeDescription(mode)),
              value: mode,
              groupValue: ref.read(calendarDisplayModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(calendarDisplayModeProvider.notifier).state = value;
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const SearchEventsDialog(),
    );
  }

  void _exportCalendar() {
    // Implementation for calendar export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calendar export feature coming soon!'),
      ),
    );
  }

  void _showAllEvents() {
    Navigator.pushNamed(context, '/events');
  }

  String _getViewName(CalendarView view) {
    switch (view) {
      case CalendarView.month:
        return 'Month View';
      case CalendarView.week:
        return 'Week View';
      case CalendarView.day:
        return 'Day View';
      case CalendarView.agenda:
        return 'Agenda View';
    }
  }

  String _getDisplayModeName(CalendarDisplayMode mode) {
    switch (mode) {
      case CalendarDisplayMode.gregorian:
        return 'Gregorian Only';
      case CalendarDisplayMode.hijri:
        return 'Hijri Only';
      case CalendarDisplayMode.both:
        return 'Both Calendars';
    }
  }

  String _getDisplayModeDescription(CalendarDisplayMode mode) {
    switch (mode) {
      case CalendarDisplayMode.gregorian:
        return 'Show only Gregorian dates';
      case CalendarDisplayMode.hijri:
        return 'Show only Hijri dates';
      case CalendarDisplayMode.both:
        return 'Show both calendar systems';
    }
  }
}

// Search Events Dialog
class SearchEventsDialog extends ConsumerStatefulWidget {
  const SearchEventsDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchEventsDialog> createState() => _SearchEventsDialogState();
}

class _SearchEventsDialogState extends ConsumerState<SearchEventsDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(eventSearchProvider(_searchQuery));

    return AlertDialog(
      title: const Text('Search Events'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for Islamic events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchResults.when(
                data: (events) => ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.description),
                      leading: CircleAvatar(
                        backgroundColor: _getEventColor(event),
                        child: Icon(
                          _getEventIcon(event.category),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showEventDetails(event);
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
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
    );
  }

  void _showEventDetails(IslamicEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (event.significances.isNotEmpty) ...[
                Text(
                  'Significance:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...event.significances.map((significance) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $significance'),
                )),
                const SizedBox(height: 16),
              ],
              if (event.practices.isNotEmpty) ...[
                Text(
                  'Recommended Practices:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...event.practices.map((practice) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $practice'),
                )),
              ],
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

  Color _getEventColor(IslamicEvent event) {
    switch (event.category) {
      case IslamicEventCategory.ramadan:
        return Colors.green;
      case IslamicEventCategory.eid:
        return Colors.red;
      case IslamicEventCategory.hajj:
        return Colors.brown;
      case IslamicEventCategory.prophet:
        return Colors.blue;
      case IslamicEventCategory.sunnah_days:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(IslamicEventCategory category) {
    switch (category) {
      case IslamicEventCategory.ramadan:
        return Icons.brightness_3;
      case IslamicEventCategory.eid:
        return Icons.celebration;
      case IslamicEventCategory.hajj:
        return Icons.terrain;
      case IslamicEventCategory.prophet:
        return Icons.person;
      case IslamicEventCategory.sunnah_days:
        return Icons.star;
      default:
        return Icons.event;
    }
  }
}