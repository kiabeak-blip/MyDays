import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  TaskScope? _filterScope;
  String? _filterMemberId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = context.watch<ap.AuthProvider>();

    var tasks = provider.tasks.toList();
    if (_filterScope != null) {
      tasks = tasks.where((t) => t.scope == _filterScope).toList();
    }
    if (_filterMemberId != null) {
      tasks =
          tasks.where((t) => t.memberIds.contains(_filterMemberId)).toList();
    }
    tasks.sort((a, b) => a.referenceDate.compareTo(b.referenceDate));

    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: Column(
        children: [
          // Scope filter row
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                FilterChip(
                  label: const Text('All scopes'),
                  selected: _filterScope == null,
                  onSelected: (_) => setState(() => _filterScope = null),
                ),
                const SizedBox(width: 8),
                ...TaskScope.values.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_scopeName(s)),
                        selected: _filterScope == s,
                        onSelected: (_) => setState(() =>
                            _filterScope = _filterScope == s ? null : s),
                      ),
                    )),
              ],
            ),
          ),
          // Member filter row
          if (provider.members.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                children: [
                  FilterChip(
                    label: const Text('All members'),
                    selected: _filterMemberId == null,
                    onSelected: (_) =>
                        setState(() => _filterMemberId = null),
                  ),
                  const SizedBox(width: 8),
                  ...provider.members.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Text(m.emoji),
                          label: Text(m.name),
                          selected: _filterMemberId == m.id,
                          onSelected: (_) => setState(() => _filterMemberId =
                              _filterMemberId == m.id ? null : m.id),
                        ),
                      )),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          provider.tasks.isEmpty
                              ? 'No tasks yet\nTap + to create the first one'
                              : 'No tasks match the filter',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final task = tasks[i];
                      // Show date header when date group changes
                      final showHeader = i == 0 ||
                          !_sameGroup(tasks[i - 1], task);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Text(
                                _groupLabel(task),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                            ),
                          TaskCard(
                            task: task,
                            members: _filterMemberId == null
                                ? provider.members
                                : provider.members
                                    .where((m) => m.id == _filterMemberId)
                                    .toList(),
                            displayCompletions:
                                task.completionsForDate(DateTime.now()),
                            onToggle: (mid) => provider.toggleCompletion(
                                task.id, mid,
                                date: DateTime.now()),
                            onToggleSubtask: (sid) =>
                                provider.toggleSubtask(task.id, sid),
                            onDelete: () => provider.deleteTask(task.id),
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TaskFormScreen(task: task)),
                            ),
                            onDuplicate: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      TaskFormScreen(duplicateFrom: task)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: auth.canAddTasks
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool _sameGroup(Task a, Task b) {
    if (a.isRecurring != b.isRecurring) return false;
    if (a.isRecurring) return a.recurrence == b.recurrence;
    if (a.scope != b.scope) return false;
    switch (a.scope) {
      case TaskScope.day:
        return isSameDay(a.referenceDate, b.referenceDate);
      case TaskScope.week:
        return Task.weekStart(a.referenceDate) ==
            Task.weekStart(b.referenceDate);
      case TaskScope.month:
        return a.referenceDate.year == b.referenceDate.year &&
            a.referenceDate.month == b.referenceDate.month;
      case TaskScope.custom:
        return false;
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _groupLabel(Task t) {
    if (t.isRecurring) {
      return switch (t.recurrence) {
        RecurrenceType.daily => '🔁 Daily — from ${DateFormat('MMM d').format(t.referenceDate)}',
        RecurrenceType.everyOtherDay => '🔁 Every other day — from ${DateFormat('MMM d').format(t.referenceDate)}',
        RecurrenceType.weekdays => '🔁 Mon–Fri — from ${DateFormat('MMM d').format(t.referenceDate)}',
        RecurrenceType.weekly => '🔁 Weekly (${DateFormat('EEEE').format(t.referenceDate)}s)',
        RecurrenceType.none => 'Recurring',
      };
    }
    switch (t.scope) {
      case TaskScope.day:
        return DateFormat('EEEE, MMM d, yyyy').format(t.referenceDate);
      case TaskScope.week:
        final ws = Task.weekStart(t.referenceDate);
        final we = Task.weekEnd(t.referenceDate);
        return 'Week: ${DateFormat('MMM d').format(ws)} – ${DateFormat('MMM d, yyyy').format(we)}';
      case TaskScope.month:
        return DateFormat('MMMM yyyy').format(t.referenceDate);
      case TaskScope.custom:
        final sorted = List<DateTime>.from(t.customDates)..sort();
        if (sorted.isEmpty) return 'Custom days';
        final preview = sorted
            .take(3)
            .map((d) => DateFormat('MMM d').format(d))
            .join(', ');
        return 'Custom: $preview${sorted.length > 3 ? ' +${sorted.length - 3} more' : ''}';
    }
  }

  String _scopeName(TaskScope s) =>
      s.name[0].toUpperCase() + s.name.substring(1);
}
