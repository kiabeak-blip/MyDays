import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/member_avatar.dart';
import '../models/family_member.dart';
import 'member_form_screen.dart';
import 'member_tasks_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final auth = context.watch<ap.AuthProvider>();
    final members = provider.members;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: members.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    auth.canManageMembers
                        ? 'No family members yet\nTap + to add someone'
                        : 'No family members yet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (_, i) {
                final member = members[i];
                return _MemberCard(
                  member: member,
                  provider: provider,
                  today: today,
                  canManage: auth.canManageMembers,
                  onViewTasks: () => _openTasks(context, member),
                  onEdit: () => _openEdit(context, member),
                );
              },
            ),
      floatingActionButton: auth.canManageMembers
          ? FloatingActionButton(
              onPressed: () => _openEdit(context, null),
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }

  void _openTasks(BuildContext context, FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberTasksScreen(member: member)),
    );
  }

  void _openEdit(BuildContext context, FamilyMember? member) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final AppProvider provider;
  final DateTime today;
  final bool canManage;
  final VoidCallback onViewTasks;
  final VoidCallback onEdit;

  const _MemberCard({
    required this.member,
    required this.provider,
    required this.today,
    required this.canManage,
    required this.onViewTasks,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(member.colorValue);
    final cs = Theme.of(context).colorScheme;

    final todayTasks = provider.tasks
        .where((t) =>
            t.memberIds.contains(member.id) && t.appliesToDate(today))
        .toList();
    final totalToday = todayTasks.length;
    final doneToday = todayTasks
        .where((t) => t.completionsForDate(today)[member.id] == true)
        .length;
    final progress = totalToday == 0 ? 0.0 : doneToday / totalToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onViewTasks,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      MemberAvatar(member: member, radius: 26),
                      if (totalToday > 0 && doneToday == totalToday)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF43A047),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            if (member.isParent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Admin',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalToday == 0
                              ? 'No tasks today'
                              : doneToday == totalToday
                                  ? 'All done! 🎉'
                                  : '$doneToday / $totalToday tasks done today',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: doneToday == totalToday &&
                                            totalToday > 0
                                        ? const Color(0xFF43A047)
                                        : cs.onSurfaceVariant,
                                    fontWeight:
                                        doneToday == totalToday && totalToday > 0
                                            ? FontWeight.w600
                                            : null,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (canManage)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit member',
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              if (totalToday > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
