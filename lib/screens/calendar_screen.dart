import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../models/task.dart';
import '../models/family_member.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = context.watch<ap.AuthProvider>();
    final cs = Theme.of(context).colorScheme;

    // Kids only see tasks assigned to themselves
    final memberId = auth.memberId;
    final visibleTasks = (auth.isParent || memberId == null)
        ? provider.tasks
        : provider.tasks.where((t) => t.memberIds.contains(memberId)).toList();

    final recurringTasks = visibleTasks
        .where((t) => t.isRecurring && t.appliesToDate(_selectedDay))
        .toList();

    final oneDayTasks = visibleTasks
        .where((t) => !t.isRecurring && t.appliesToDate(_selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyDays'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => setState(() {
                _format = _format == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              }),
              child: Text(_format == CalendarFormat.month
                  ? 'Week view'
                  : 'Month view'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _format,
            eventLoader: (day) => provider.getTasksForDate(day),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (f) => setState(() => _focusedDay = f),
            rowHeight: 44,
            calendarStyle: CalendarStyle(
              markersMaxCount: 4,
              markerDecoration: BoxDecoration(
                  color: cs.primary, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                  color: cs.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                  color: cs.primaryContainer, shape: BoxShape.circle),
              todayTextStyle: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          // ── Member aggregate bar ──────────────────────────────────
          if (provider.members.isNotEmpty)
            _MemberAggregateBar(
              members: provider.members,
              tasks: provider.getTasksForDate(_selectedDay),
              date: _selectedDay,
            ),
          Expanded(
            child: ListView(
              children: [
                _Section(
                  title: 'Recurring Tasks',
                  subtitle: DateFormat('EEEE, MMM d').format(_selectedDay),
                  tasks: recurringTasks,
                  date: _selectedDay,
                  members: provider.members,
                  onToggle: (tid, mid) =>
                      provider.toggleCompletion(tid, mid, date: _selectedDay),
                  onToggleSubtask: (tid, sid) =>
                      provider.toggleSubtask(tid, sid),
                  onDelete: (tid) => provider.deleteTask(tid),
                  onEdit: (t) => _pushForm(context, task: t),
                  onAdd: () => _pushForm(context,
                      recurrence: RecurrenceType.daily),
                  addLabel: '+ Recurring',
                ),
                _Section(
                  title: 'Tasks',
                  subtitle: DateFormat('EEEE, MMM d').format(_selectedDay),
                  tasks: oneDayTasks,
                  date: _selectedDay,
                  members: provider.members,
                  onToggle: (tid, mid) =>
                      provider.toggleCompletion(tid, mid),
                  onToggleSubtask: (tid, sid) =>
                      provider.toggleSubtask(tid, sid),
                  onDelete: (tid) => provider.deleteTask(tid),
                  onEdit: (t) => _pushForm(context, task: t),
                  onAdd: () => _pushForm(context),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: auth.canAddTasks
          ? FloatingActionButton(
              onPressed: () => _pushForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _pushForm(
    BuildContext context, {
    Task? task,
    TaskScope? scope,
    RecurrenceType? recurrence,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          task: task,
          initialDate: _selectedDay,
          initialScope: scope,
          initialRecurrence: recurrence,
        ),
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Task> tasks;
  final DateTime date;
  final List members;
  final void Function(String, String) onToggle;
  final void Function(String, String) onToggleSubtask;
  final void Function(String) onDelete;
  final void Function(Task) onEdit;
  final VoidCallback onAdd;
  final String addLabel;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.date,
    required this.members,
    required this.onToggle,
    required this.onToggleSubtask,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    this.addLabel = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canAdd = context.watch<ap.AuthProvider>().canAddTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (canAdd)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(addLabel),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'No tasks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          )
        else
          ...tasks.map(
            (t) => TaskCard(
              task: t,
              members: members.cast(),
              displayCompletions: t.completionsForDate(date),
              onToggle: (mid) => onToggle(t.id, mid),
              onToggleSubtask: (sid) => onToggleSubtask(t.id, sid),
              onDelete: () => onDelete(t.id),
              onEdit: () => onEdit(t),
            ),
          ),
        const Divider(height: 1, indent: 16),
      ],
    );
  }
}

// ── Member aggregate bar ──────────────────────────────────────────────────

class _MemberAggregateBar extends StatelessWidget {
  final List<FamilyMember> members;
  final List<Task> tasks;
  final DateTime date;

  const _MemberAggregateBar({
    required this.members,
    required this.tasks,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: members.map((m) {
          final memberTasks =
              tasks.where((t) => t.memberIds.contains(m.id)).toList();
          final done = memberTasks
              .where((t) => t.completionsForDate(date)[m.id] == true)
              .length;
          final total = memberTasks.length;
          final color = Color(m.colorValue);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.emoji,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        total == 0 ? '–' : '$done/$total',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: done == total && total > 0
                              ? const Color(0xFF43A047)
                              : color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 5,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(
                        done == total && total > 0
                            ? const Color(0xFF43A047)
                            : color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
