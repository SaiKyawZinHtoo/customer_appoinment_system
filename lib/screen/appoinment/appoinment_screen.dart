import 'package:flutter/material.dart';
import 'package:customer_appointment_system/widget/color.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/screen/customer/customer_information_screen.dart';
import 'package:customer_appointment_system/screen/customer/customer_list_information_screen.dart';

/// Simple appointment calendar UI built on top of the app's theme.
class AppoinmentScreen extends StatefulWidget {
  const AppoinmentScreen({super.key});

  @override
  State<AppoinmentScreen> createState() => _AppoinmentScreenState();
}

class _AppoinmentScreenState extends State<AppoinmentScreen> {
  @override
  void initState() {
    super.initState();
    AppointmentRepository.instance.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    AppointmentRepository.instance.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() => setState(() {});

  DateTime? _selectedDate;
  DateTime _displayMonth = DateTime.now(); // first month shown (current month)

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Month data — generate a grid of dates for the display month and show
    // leading/trailing disabled days.
    final month = _displayMonth.month;
    final year = _displayMonth.year;
    final firstOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstOfMonth.weekday % 7; // Sun=0..Sat=6
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    final days = List<int>.generate(42, (i) {
      final dayIndex = i - firstWeekday + 1;
      return dayIndex; // may be <=0 or > daysInMonth
    });

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            // show a back button when possible (go up / back)
            if (Navigator.canPop(context)) {
              return IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              );
            }
            // otherwise keep a small spacer to keep title aligned
            return const SizedBox.shrink();
          },
        ),
        // Keep AppBar simple: show a short title only to avoid overflow.
        title: const Text('Appointment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CustomScrollView(
            slivers: [
              // Month navigator (moved below AppBar for a cleaner AppBar UX)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Prev month button
                      IconButton(
                        tooltip: 'Previous month',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          final today = DateTime.now();
                          final currentIndex = today.year * 12 + today.month;
                          final displayIndex =
                              _displayMonth.year * 12 + _displayMonth.month;
                          final canPrev = displayIndex > currentIndex - 12;
                          if (canPrev) {
                            setState(
                              () => _displayMonth = DateTime(
                                _displayMonth.year,
                                _displayMonth.month - 1,
                                1,
                              ),
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => _pickMonthYear(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: theme.iconTheme.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Next month button
                      IconButton(
                        tooltip: 'Next month',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          final today = DateTime.now();
                          final currentIndex = today.year * 12 + today.month;
                          final displayIndex =
                              _displayMonth.year * 12 + _displayMonth.month;
                          final canNext = displayIndex < currentIndex + 12;
                          if (canNext) {
                            setState(
                              () => _displayMonth = DateTime(
                                _displayMonth.year,
                                _displayMonth.month + 1,
                                1,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Weekday header
              SliverToBoxAdapter(
                child: _WeekdayHeader(isDark: isDark, theme: theme),
              ),

              // Spacing
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Days grid as a SliverGrid so the whole page scrolls smoothly
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final day = days[i];
                    final isActive = day > 0 && day <= daysInMonth;
                    final today = DateTime.now();
                    final todayDate = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    // Create a cellDate for this grid cell; for inactive cells
                    // this may point to a neighbouring month, but we only
                    // count markers when the cell is part of the displayed month.
                    final cellDate = DateTime(year, month, day);
                    final isSelectable =
                        isActive && !cellDate.isBefore(todayDate);
                    // Only compute markerCount for active days (inside the month)
                    final int markerCount = isActive
                        ? AppointmentRepository.instance
                              .getForDate(cellDate)
                              .where((c) => c.completed != true)
                              .length
                        : 0;
                    final showMarker = isActive && markerCount > 0;
                    final cellKey = ValueKey(
                      'day-${cellDate.year}-${cellDate.month}-$day',
                    );
                    return _DayCell(
                      key: cellKey,
                      day: day,
                      isActive: isActive,
                      isSunday: (i % 7) == 0,
                      isSaturday: (i % 7) == 6,
                      showMarker: showMarker,
                      markerCount: markerCount,
                      isSelected:
                          _selectedDate != null &&
                          DateTime(
                            year,
                            month,
                            day,
                          ).isAtSameMomentAs(_selectedDate!),
                      isSelectable: isSelectable,
                      onTap: isSelectable
                          ? () {
                              // If this date has appointments, navigate to the
                              // customer list for that date (same behaviour as
                              // tapping an item in the selected-day details).
                              if (markerCount > 0) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CustomerListInformationScreen(
                                          date: cellDate,
                                        ),
                                  ),
                                );
                              } else {
                                // otherwise just select the date to show details
                                setState(() => _selectedDate = cellDate);
                              }
                            }
                          : null,
                      theme: theme,
                      isDark: isDark,
                    );
                  }, childCount: days.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.4,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Selected day details / appointment list
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                  ),
                  child: _selectedDate == null
                      ? Center(
                          child: Text(
                            'Select a day to view appointments',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Appointments for ${_monthNames[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                // Show only remaining (not completed) appointments in the
                                // selected-day summary so the calendar marker counts
                                // down as items are marked done.
                                final customersForSelected =
                                    AppointmentRepository.instance
                                        .getForDate(_selectedDate!)
                                        .where((c) => c.completed != true)
                                        .toList();
                                if (customersForSelected.isEmpty) {
                                  return Text(
                                    'No appointments',
                                    style: theme.textTheme.bodyMedium,
                                  );
                                }
                                return Column(
                                  children: customersForSelected
                                      .map(
                                        (c) => ListTile(
                                          title: Text(c.displayTitle),
                                          leading: const Icon(Icons.event_note),
                                          onTap: () {
                                            // Open the customer list/detail screen
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CustomerListInformationScreen(
                                                      date: _selectedDate!,
                                                      initialCustomerId: c.id,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open full customer form for the selected date
          if (_selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a day first')),
            );
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomerInformationScreen(
                initialAppointmentDate: _selectedDate,
              ),
            ),
          );
          // result is a Customer or null; repository will notify and rebuild
          if (result != null) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Appointment added')),
            );
          }
        },
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickMonthYear(BuildContext context) async {
    // show a bottom sheet with month and year selectors
    final now = DateTime.now();
    int selMonth = _displayMonth.month;
    int selYear = _displayMonth.year;

    final minYear = now.year - 5;
    final maxYear = now.year + 5;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (ctx2, setStateSB) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pick month & year',
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: selMonth,
                            isExpanded: true,
                            items: List.generate(12, (i) => i + 1)
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(_monthNames[m - 1]),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setStateSB(() => selMonth = v ?? selMonth),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<int>(
                            value: selYear,
                            isExpanded: true,
                            items:
                                List.generate(
                                      maxYear - minYear + 1,
                                      (i) => minYear + i,
                                    )
                                    .map(
                                      (y) => DropdownMenuItem(
                                        value: y,
                                        child: Text('$y'),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) =>
                                setStateSB(() => selYear = v ?? selYear),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // apply selection
                            setState(() {
                              _displayMonth = DateTime(selYear, selMonth, 1);
                              _selectedDate =
                                  null; // reset selection when month changes
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.isDark, required this.theme});
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: weekdays.map((w) {
        final isSunday = w == 'Sun';
        final isSaturday = w == 'Sat';
        final bg = isSunday
            ? AppColors.error
            : isSaturday
            ? AppColors.primaryLight
            : Colors.transparent;
        final fg = Colors.white;
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              w,
              style: theme.textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.day,
    required this.isActive,
    required this.isSunday,
    required this.isSaturday,
    required this.showMarker,
    required this.isSelectable,
    required this.isSelected,
    this.onTap,
    required this.markerCount,
    required this.theme,
    required this.isDark,
  });
  final int day;
  final bool isActive;
  final bool isSunday;
  final bool isSaturday;
  final bool showMarker;
  final int markerCount;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isSelectable;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      color: isSelectable
          ? (isDark ? Colors.white : AppColors.textPrimary)
          : Colors.grey.shade500,
    );
    final cellBg = isSunday
        ? AppColors.error.withAlpha(0x33)
        : isSaturday
        ? AppColors.primaryLight.withAlpha(0x1A)
        : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : (isDark ? Colors.white10 : Colors.grey.shade300),
            width: isSelected ? 2.0 : 1.0,
          ),
          color: cellBg,
        ),
        child: Stack(
          children: [
            if (!isActive)
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                ),
              ),
            if (isActive)
              Align(
                alignment: Alignment.center,
                child: Text('$day', style: textStyle),
              ),
            if (showMarker)
              Positioned(
                left: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.error,
                  child: Text(
                    '$markerCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
