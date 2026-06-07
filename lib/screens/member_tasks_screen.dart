import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/family_member.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as ap;
import 'task_form_screen.dart';

class MemberTasksScreen extends StatefulWidget {
  final FamilyMember member;

  const MemberTasksScreen({super.key, required this.member});

  @override
  State<MemberTasksScreen> createState() => _MemberTasksScreenState();
}

class _MemberTasksScreenState extends State<MemberTasksScreen> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final member = widget.member;
    final color = Color(member.colorValue);
    final cs = Theme.of(context).colorScheme;

    // All tasks assigned to this member that apply to the selected date
    final tasksForDay = provider.tasks
        .where((t) =>
            t.memberIds.contains(member.id) && t.appliesToDate(_date))
        .toList();

    // Split into recurring vs one-time
    final recurring = tasksForDay.where((t) => t.isRecurring).toList();
    final oneTime = tasksForDay.where((t) => !t.isRecurring).toList();

    // Count done for today
    final doneCount = tasksForDay
        .where((t) => t.completionsForDate(_date)[member.id] == true)
        .length;
    final total = tasksForDay.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      Color.lerp(color, Colors.black, 0.25)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(member.emoji,
                            style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        member.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          '$doneCount / $total done today',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // ── Date navigation bar ────────────────────────────────────
            Container(
              color: cs.surfaceContainerLow,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() =>
                        _date = _date.subtract(const Duration(days: 1))),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Column(
                        children: [
                          Text(
                            _isToday
                                ? AppLocalizations.of(context)!.today
                                : _isYesterday
                                    ? AppLocalizations.of(context)!.yesterday
                                    : _isTomorrow
                                        ? AppLocalizations.of(context)!.tomorrow
                                        : DateFormat('EEEE')
                                            .format(_date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isToday ? color : cs.onSurface,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM d, yyyy').format(_date),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() =>
                        _date = _date.add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),
            // ── Progress bar ──────────────────────────────────────────
            if (total > 0)
              LinearProgressIndicator(
                value: total == 0 ? 0 : doneCount / total,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            // ── Task list ─────────────────────────────────────────────
            Expanded(
              child: tasksForDay.isEmpty
                  ? _EmptyState(
                      member: member,
                      date: _date,
                      onAdd: () => _addTask(context),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        if (recurring.isNotEmpty) ...[
                          _SectionHeader(
                              label: AppLocalizations.of(context)!.recurringTasks,
                              icon: Icons.repeat,
                              color: const Color(0xFF43A047)),
                          ...recurring.map((t) => _TaskRow(
                                task: t,
                                member: member,
                                date: _date,
                                onToggle: () => provider.toggleCompletion(
                                    t.id, member.id,
                                    date: _date),
                                onEdit: () => _editTask(context, t),
                              )),
                        ],
                        if (oneTime.isNotEmpty) ...[
                          _SectionHeader(
                              label: AppLocalizations.of(context)!.scheduled,
                              icon: Icons.event,
                              color: cs.primary),
                          ...oneTime.map((t) => _TaskRow(
                                task: t,
                                member: member,
                                date: _date,
                                onToggle: () => provider.toggleCompletion(
                                    t.id, member.id),
                                onEdit: () => _editTask(context, t),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: context.watch<ap.AuthProvider>().canAddTasks
          ? FloatingActionButton(
              backgroundColor: color,
              foregroundColor: Colors.white,
              onPressed: () => _addTask(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool get _isToday {
    final now = DateTime.now();
    return _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
  }

  bool get _isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return _date.year == y.year &&
        _date.month == y.month &&
        _date.day == y.day;
  }

  bool get _isTomorrow {
    final t = DateTime.now().add(const Duration(days: 1));
    return _date.year == t.year &&
        _date.month == t.month &&
        _date.day == t.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          initialDate: _date,
          initialScope: TaskScope.day,
        ),
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }
}

// ── Task row ──────────────────────────────────────────────────────────────

class _TaskRow extends StatefulWidget {
  final Task task;
  final FamilyMember member;
  final DateTime date;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TaskRow({
    required this.task,
    required this.member,
    required this.date,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.member.colorValue);
    final done =
        widget.task.completionsForDate(widget.date)[widget.member.id] == true;
    final cs = Theme.of(context).colorScheme;
    final hasSubtasks = widget.task.subtasks.isNotEmpty;
    final doneSteps = widget.task.subtasksDoneCountForDate(widget.date);
    final totalSteps = widget.task.subtasks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Main row ────────────────────────────────────────────────
            InkWell(
              onTap: hasSubtasks
                  ? () => setState(() => _expanded = !_expanded)
                  : widget.onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Completion toggle
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? color : Colors.transparent,
                          border: Border.all(
                            color: done
                                ? color
                                : cs.outline.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: done
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Emoji icon (if set)
                    if (widget.task.iconEmoji.isNotEmpty) ...[
                      Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(widget.task.iconEmoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    ],
                    // Task info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: done
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                          ),
                          if (widget.task.description.isNotEmpty)
                            Text(
                              widget.task.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          // Subtask progress hint when collapsed
                          if (hasSubtasks && !_expanded) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.checklist_rounded,
                                    size: 12,
                                    color:
                                        color.withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  '$doneSteps / $totalSteps steps',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Scope/recurrence badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (widget.task.isRecurring
                                ? const Color(0xFF43A047)
                                : cs.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.task.isRecurring
                            ? _recurrenceLabel(widget.task.recurrence)
                            : widget.task.scope.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.task.isRecurring
                              ? const Color(0xFF43A047)
                              : cs.primary,
                        ),
                      ),
                    ),
                    // Expand chevron
                    if (hasSubtasks) ...[
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more,
                            size: 20, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // ── Expanded subtask list ────────────────────────────────────
            if (_expanded && hasSubtasks) ...[
              Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.5)),
              ...widget.task.subtasks.map((s) => _SubtaskTile(
                    subtask: s,
                    done: widget.task.isSubtaskDoneForDate(s.id, widget.date),
                    color: color,
                    onToggle: () => context
                        .read<AppProvider>()
                        .toggleSubtask(widget.task.id, s.id, date: widget.date),
                  )),
              // Footer: progress + edit link
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(14, 4, 10, 10),
                child: Row(
                  children: [
                    // Mini progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalSteps == 0
                              ? 0
                              : doneSteps / totalSteps,
                          backgroundColor:
                              color.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$doneSteps/$totalSteps',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onEdit,
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _recurrenceLabel(RecurrenceType r) => switch (r) {
        RecurrenceType.daily => 'DAILY',
        RecurrenceType.everyOtherDay => 'ALT DAY',
        RecurrenceType.weekdays => 'MON–FRI',
        RecurrenceType.weekly => 'WEEKLY',
        RecurrenceType.none => '',
      };
}

// ── Subtask tile ──────────────────────────────────────────────────────────

class _SubtaskTile extends StatelessWidget {
  final SubTask subtask;
  final bool done;
  final Color color;
  final VoidCallback onToggle;

  const _SubtaskTile({
    required this.subtask,
    required this.done,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                key: ValueKey(done),
                size: 22,
                color: done
                    ? color
                    : cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  fontSize: 14,
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final FamilyMember member;
  final DateTime date;
  final VoidCallback onAdd;

  const _EmptyState(
      {required this.member, required this.date, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isWeekend ? '🎉' : '✅',
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            isWeekend
                ? AppLocalizations.of(context)!.enjoyWeekend
                : AppLocalizations.of(context)!.noTasksForMember(member.name),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addTask),
          ),
        ],
      ),
    );
  }
}
