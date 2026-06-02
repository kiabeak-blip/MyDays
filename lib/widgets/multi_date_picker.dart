import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MultiDatePicker extends StatefulWidget {
  final List<DateTime> initialDates;

  const MultiDatePicker({super.key, required this.initialDates});

  /// Opens a bottom sheet and returns the selected dates, or null if cancelled.
  static Future<List<DateTime>?> show(
      BuildContext context, List<DateTime> initial) {
    return showModalBottomSheet<List<DateTime>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiDatePicker(initialDates: initial),
    );
  }

  @override
  State<MultiDatePicker> createState() => _MultiDatePickerState();
}

class _MultiDatePickerState extends State<MultiDatePicker> {
  late Set<DateTime> _selected;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sorted = _selected.toList()..sort();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select days',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        _selected.isEmpty
                            ? 'Tap days on the calendar to select them'
                            : '${_selected.length} day${_selected.length == 1 ? '' : 's'} selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ),
          // Selected days chips
          if (_selected.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: sorted
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label: Text(DateFormat('MMM d').format(d),
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: cs.primaryContainer,
                            labelStyle:
                                TextStyle(color: cs.onPrimaryContainer),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _selected.remove(d)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 4),
          // Calendar
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay:
                    DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  final d = DateTime(day.year, day.month, day.day);
                  return _selected.contains(d);
                },
                onDaySelected: (selected, focused) {
                  final d =
                      DateTime(selected.year, selected.month, selected.day);
                  setState(() {
                    if (_selected.contains(d)) {
                      _selected.remove(d);
                    } else {
                      _selected.add(d);
                    }
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (f) => setState(() => _focusedDay = f),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),
          // Done button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, sorted),
                child: Text(_selected.isEmpty
                    ? 'Select at least one day'
                    : 'Done — ${_selected.length} day${_selected.length == 1 ? '' : 's'}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
