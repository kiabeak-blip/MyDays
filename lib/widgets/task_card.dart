import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/family_member.dart';
import '../providers/auth_provider.dart' as ap;
import 'scope_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final List<FamilyMember> members;
  final Map<String, bool> displayCompletions;
  final void Function(String memberId) onToggle;
  final void Function(String subtaskId) onToggleSubtask;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.members,
    required this.displayCompletions,
    required this.onToggle,
    required this.onToggleSubtask,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final assignedMembers =
        members.where((m) => task.memberIds.contains(m.id)).toList();
    final completedCount =
        task.memberIds.where((id) => displayCompletions[id] == true).length;
    final isFullyDone = task.memberIds.isNotEmpty &&
        task.memberIds.every((id) => displayCompletions[id] == true);
    final hasIcon = task.iconEmoji.isNotEmpty;

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large emoji icon column
              if (hasIcon) ...[
                Container(
                  width: 52,
                  height: 52,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(task.iconEmoji,
                        style: const TextStyle(fontSize: 30)),
                  ),
                ),
              ],
              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (task.isRecurring)
                          _RecurrenceBadge(recurrence: task.recurrence)
                        else
                          ScopeBadge(scope: task.scope),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: isFullyDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isFullyDone
                                      ? cs.onSurfaceVariant
                                      : cs.onSurface,
                                ),
                          ),
                        ),
                        if (task.memberIds.isNotEmpty)
                          Text(
                            '$completedCount/${task.memberIds.length}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 18),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showMenu(context),
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          task.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    // Subtask checkboxes
                    if (task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...task.subtasks.map((s) => _SubtaskRow(
                            subtask: s,
                            onToggle: () => onToggleSubtask(s.id),
                          )),
                      const SizedBox(height: 2),
                      Text(
                        '${task.subtaskDoneCount}/${task.subtasks.length} steps done',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                    // Member chips
                    if (assignedMembers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: assignedMembers
                            .map((m) => _MemberChip(
                                  member: m,
                                  done: displayCompletions[m.id] == true,
                                  onTap: () => onToggle(m.id),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final auth = context.read<ap.AuthProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (auth.canEditTasks)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit task'),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit();
                },
              ),
            if (auth.canDeleteTasks)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(ctx).colorScheme.error),
                title: Text('Delete task',
                    style:
                        TextStyle(color: Theme.of(ctx).colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
            if (!auth.canEditTasks && !auth.canDeleteTasks)
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No actions available'),
                subtitle: Text('Ask a parent to edit or delete tasks'),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Subtask row ───────────────────────────────────────────────────────────

class _SubtaskRow extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onToggle;

  const _SubtaskRow({required this.subtask, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              subtask.completed
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 18,
              color: subtask.completed ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  fontSize: 13,
                  decoration:
                      subtask.completed ? TextDecoration.lineThrough : null,
                  color: subtask.completed
                      ? cs.onSurfaceVariant
                      : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Member chip ───────────────────────────────────────────────────────────

class _MemberChip extends StatelessWidget {
  final FamilyMember member;
  final bool done;
  final VoidCallback onTap;

  const _MemberChip({
    required this.member,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(member.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: done ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(member.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              member.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: done ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: done ? Colors.white : color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recurrence badge ──────────────────────────────────────────────────────

class _RecurrenceBadge extends StatelessWidget {
  final RecurrenceType recurrence;
  const _RecurrenceBadge({required this.recurrence});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF43A047);
    final label = switch (recurrence) {
      RecurrenceType.daily => 'DAILY',
      RecurrenceType.weekdays => 'MON–FRI',
      RecurrenceType.weekly => 'WEEKLY',
      RecurrenceType.none => '',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat, size: 10, color: Color(0xFF43A047)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF43A047),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
