import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../widgets/member_avatar.dart';
import '../widgets/multi_date_picker.dart';
import '../widgets/icon_picker.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;
  final TaskScope? initialScope;
  final RecurrenceType? initialRecurrence;

  const TaskFormScreen({
    super.key,
    this.task,
    this.initialDate,
    this.initialScope,
    this.initialRecurrence,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late TaskScope _scope;
  late RecurrenceType _recurrence;
  late DateTime _referenceDate;
  late List<DateTime> _customDates;
  late Set<String> _selectedMemberIds;
  late String _iconEmoji;
  late List<SubTask> _subtasks;
  final _uuid = const Uuid();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _scope = TaskScope.custom;
    _recurrence =
        t?.recurrence ?? widget.initialRecurrence ?? RecurrenceType.none;
    _referenceDate = t?.referenceDate ?? widget.initialDate ?? DateTime.now();
    _customDates = t?.customDates != null ? List.from(t!.customDates) : [];
    _selectedMemberIds = t != null ? Set.from(t.memberIds) : {};
    _iconEmoji = t?.iconEmoji ?? '';
    _subtasks = t?.subtasks != null ? List.from(t!.subtasks) : [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Icon + Title row ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickIcon,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(right: 12, top: 4),
                    decoration: BoxDecoration(
                      color: _iconEmoji.isEmpty
                          ? cs.surfaceContainerHighest
                          : cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _iconEmoji.isEmpty
                            ? cs.outline.withValues(alpha: 0.4)
                            : cs.primary,
                        width: _iconEmoji.isEmpty ? 1 : 2,
                      ),
                    ),
                    child: _iconEmoji.isEmpty
                        ? Icon(Icons.add_reaction_outlined,
                            color: cs.onSurfaceVariant)
                        : Center(
                            child: Text(_iconEmoji,
                                style: const TextStyle(fontSize: 28))),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Task title *',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                ),
              ],
            ),
            if (_iconEmoji.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text('Tap the box to add an icon',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant)),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Short description (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            // ── Checklist items ─────────────────────────────────────
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Checklist',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add step'),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            if (_subtasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    final item = _subtasks.removeAt(oldIdx);
                    _subtasks.insert(newIdx, item);
                  });
                },
                children: _subtasks.asMap().entries.map((e) {
                  final idx = e.key;
                  final s = e.value;
                  return _SubtaskField(
                    key: ValueKey(s.id),
                    subtask: s,
                    onChanged: (v) => setState(() {
                      _subtasks[idx] = s.copyWith(title: v);
                    }),
                    onDelete: () =>
                        setState(() => _subtasks.removeAt(idx)),
                  );
                }).toList(),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 4),
                child: Text(
                  'Add steps for a young child to follow one by one',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            const SizedBox(height: 24),
            // ── Recurrence ──────────────────────────────────────────────
            Text('Repeats',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RecurrenceChip(
                  label: 'One-time',
                  icon: Icons.looks_one_outlined,
                  selected: _recurrence == RecurrenceType.none,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.none),
                ),
                _RecurrenceChip(
                  label: 'Daily',
                  icon: Icons.repeat,
                  selected: _recurrence == RecurrenceType.daily,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.daily),
                ),
                _RecurrenceChip(
                  label: 'Mon – Fri',
                  icon: Icons.date_range,
                  selected: _recurrence == RecurrenceType.weekdays,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.weekdays),
                ),
                _RecurrenceChip(
                  label: 'Weekly',
                  icon: Icons.view_week,
                  selected: _recurrence == RecurrenceType.weekly,
                  onTap: () =>
                      setState(() => _recurrence = RecurrenceType.weekly),
                ),
              ],
            ),
            if (_recurrence != RecurrenceType.none) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.today, color: cs.primary),
                title: const Text('Starts from'),
                subtitle: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_referenceDate),
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w500),
                ),
                onTap: _pickDate,
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: cs.outline.withValues(alpha: 0.4))),
              ),
            ],
            if (_recurrence == RecurrenceType.none) ...[
              const SizedBox(height: 24),
              Text('Select days',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _CustomDateTile(
                dates: _customDates,
                onTap: _pickCustomDates,
                colorScheme: cs,
              ),
            ], // end if recurrence == none
            const SizedBox(height: 24),
            Text('Assign to family members',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (provider.members.isEmpty)
              Text(
                'No family members yet — add them from the Members tab.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.members.map((m) {
                  final selected = _selectedMemberIds.contains(m.id);
                  return FilterChip(
                    avatar: MemberAvatar(member: m, radius: 12),
                    label: Text(m.name),
                    selected: selected,
                    onSelected: (v) => setState(() => v
                        ? _selectedMemberIds.add(m.id)
                        : _selectedMemberIds.remove(m.id)),
                  );
                }).toList(),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
          ),
        ),
      ),
    );
  }

  bool get _canSave =>
      _scope != TaskScope.custom || _customDates.isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _referenceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _referenceDate = picked);
  }

  Future<void> _pickCustomDates() async {
    final result = await MultiDatePicker.show(context, _customDates);
    if (result != null) setState(() => _customDates = result);
  }

  Future<void> _pickIcon() async {
    final result = await IconPicker.show(context, _iconEmoji);
    if (result != null) setState(() => _iconEmoji = result);
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(SubTask(id: _uuid.v4(), title: ''));
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scope == TaskScope.custom && _customDates.isEmpty) return;

    final provider = context.read<AppProvider>();
    final memberIds = _selectedMemberIds.toList();

    final effectiveRefDate = _scope == TaskScope.custom && _customDates.isNotEmpty
        ? (List.from(_customDates)..sort()).first as DateTime
        : _referenceDate;

    if (_isEditing) {
      final existing = widget.task!;

      // For recurring tasks, ask whether to apply to all or only today & future
      if (existing.isRecurring && mounted) {
        final choice = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Apply changes to…'),
            content: const Text(
              'This is a recurring task. Do you want to update all occurrences, or only today and future dates?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: const Text('Cancel'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, 'all'),
                child: const Text('All occurrences'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'forward'),
                child: const Text('Today & future'),
              ),
            ],
          ),
        );
        if (!mounted || choice == null || choice == 'cancel') return;

        final updatedTask = existing.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          iconEmoji: _iconEmoji,
          subtasks: _subtasks.where((s) => s.title.trim().isNotEmpty).toList(),
          recurrence: _recurrence,
          referenceDate: effectiveRefDate,
          memberIds: memberIds,
        );

        if (choice == 'forward') {
          await provider.splitRecurringTask(
            original: existing,
            updated: updatedTask,
            fromDate: DateTime.now(),
          );
        } else {
          await provider.updateTask(updatedTask);
        }
        if (mounted) Navigator.pop(context);
        return;
      }

      // Non-recurring task edit
      final updatedCompletions = <String, bool>{
        for (final id in memberIds) id: existing.completions[id] ?? false,
      };
      await provider.updateTask(existing.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        iconEmoji: _iconEmoji,
        subtasks: _subtasks.where((s) => s.title.trim().isNotEmpty).toList(),
        scope: _scope,
        recurrence: _recurrence,
        referenceDate: effectiveRefDate,
        customDates: _customDates,
        memberIds: memberIds,
        completions: updatedCompletions,
      ));
    } else {
      await provider.addTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        iconEmoji: _iconEmoji,
        subtasks: _subtasks.where((s) => s.title.trim().isNotEmpty).toList(),
        scope: _scope,
        recurrence: _recurrence,
        referenceDate: effectiveRefDate,
        customDates: List.from(_customDates),
        memberIds: memberIds,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final nav = Navigator.of(context);
      await context.read<AppProvider>().deleteTask(widget.task!.id);
      nav.pop();
    }
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────

class _RecurrenceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RecurrenceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? const Color(0xFF43A047) : cs.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF43A047).withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF43A047)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _CustomDateTile extends StatelessWidget {
  final List<DateTime> dates;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _CustomDateTile({
    required this.dates,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final sorted = List<DateTime>.from(dates)..sort();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  dates.isEmpty
                      ? 'Tap to select specific days'
                      : '${dates.length} day${dates.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    color: dates.isEmpty ? cs.onSurfaceVariant : cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
            if (sorted.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sorted
                    .map((d) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            DateFormat('EEE, MMM d').format(d),
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubtaskField extends StatefulWidget {
  final SubTask subtask;
  final void Function(String) onChanged;
  final VoidCallback onDelete;

  const _SubtaskField({
    super.key,
    required this.subtask,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_SubtaskField> createState() => _SubtaskFieldState();
}

class _SubtaskFieldState extends State<_SubtaskField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.subtask.title);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: 'Step description…',
                isDense: true,
                border: UnderlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: widget.onDelete,
          ),
          const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
