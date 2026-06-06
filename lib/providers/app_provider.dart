import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../models/task.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  final _svc = FirebaseService();
  final _uuid = const Uuid();

  String? _familyId;
  List<FamilyMember> _members = [];
  List<Task> _tasks = [];

  StreamSubscription? _membersSubscription;
  StreamSubscription? _tasksSubscription;

  List<FamilyMember> get members => List.unmodifiable(_members);
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoaded => _familyId != null;

  void init(String familyId) {
    if (_familyId == familyId) return;
    _familyId = familyId;

    _membersSubscription?.cancel();
    _tasksSubscription?.cancel();

    _membersSubscription = _svc.watchMembers(familyId).listen((list) {
      _members = list;
      notifyListeners();
    });

    _tasksSubscription = _svc.watchTasks(familyId).listen((list) {
      _tasks = list;
      notifyListeners();
    });
  }

  void reset() {
    _membersSubscription?.cancel();
    _tasksSubscription?.cancel();
    _familyId = null;
    _members = [];
    _tasks = [];
    notifyListeners();
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Future<void> addMember(
    String name,
    int colorValue,
    String emoji, {
    MemberRole role = MemberRole.child,
  }) async {
    if (_familyId == null) return;
    final member = FamilyMember(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      emoji: emoji,
      role: role,
    );
    await _svc.setMember(_familyId!, member);
  }

  Future<void> updateMember(FamilyMember member) async {
    if (_familyId == null) return;
    await _svc.setMember(_familyId!, member);
  }

  Future<void> deleteMember(String memberId) async {
    if (_familyId == null) return;
    await _svc.deleteMember(_familyId!, memberId);
    // Remove member from all tasks
    for (final task in _tasks.where((t) => t.memberIds.contains(memberId))) {
      final newIds = task.memberIds.where((id) => id != memberId).toList();
      final newCompletions = Map.of(task.completions)..remove(memberId);
      final newDateCompletions = task.dateCompletions.map(
        (date, memberMap) =>
            MapEntry(date, Map.of(memberMap)..remove(memberId)),
      );
      await _svc.setTask(
        _familyId!,
        task.copyWith(
          memberIds: newIds,
          completions: newCompletions,
          dateCompletions: newDateCompletions,
        ),
      );
    }
  }

  FamilyMember? getMember(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Future<void> addTask({
    required String title,
    String description = '',
    String iconEmoji = '',
    List<SubTask> subtasks = const [],
    required TaskScope scope,
    RecurrenceType recurrence = RecurrenceType.none,
    required DateTime referenceDate,
    List<DateTime> customDates = const [],
    required List<String> memberIds,
  }) async {
    if (_familyId == null) return;
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      iconEmoji: iconEmoji,
      subtasks: subtasks,
      scope: scope,
      recurrence: recurrence,
      referenceDate: referenceDate,
      customDates: customDates,
      memberIds: memberIds,
      completions: {for (final id in memberIds) id: false},
      dateCompletions: const {},
      createdAt: DateTime.now(),
    );
    await _svc.setTask(_familyId!, task);
  }

  Future<void> updateTask(Task task) async {
    if (_familyId == null) return;
    await _svc.setTask(_familyId!, task);
  }

  /// Splits a recurring task at [fromDate]: old task ends the day before,
  /// new task starts at [fromDate] with the updated content.
  Future<void> splitRecurringTask({
    required Task original,
    required Task updated,
    required DateTime fromDate,
  }) async {
    if (_familyId == null) return;
    final yesterday = fromDate.subtract(const Duration(days: 1));

    // End the original task at yesterday
    final ended = original.copyWith(endDate: yesterday);
    await _svc.setTask(_familyId!, ended);

    // Create the new task starting from today with updated content
    final newTask = Task(
      id: _uuid.v4(),
      title: updated.title,
      description: updated.description,
      iconEmoji: updated.iconEmoji,
      subtasks: updated.subtasks,
      scope: updated.scope,
      recurrence: updated.recurrence,
      referenceDate: DateTime(fromDate.year, fromDate.month, fromDate.day),
      customDates: updated.customDates,
      memberIds: updated.memberIds,
      completions: {for (final id in updated.memberIds) id: false},
      dateCompletions: const {},
      createdAt: DateTime.now(),
    );
    await _svc.setTask(_familyId!, newTask);
  }

  Future<void> deleteTask(String taskId) async {
    if (_familyId == null) return;
    await _svc.deleteTask(_familyId!, taskId);
  }

  Future<void> toggleCompletion(
    String taskId,
    String memberId, {
    DateTime? date,
  }) async {
    if (_familyId == null) return;
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final task = _tasks[idx];

    Task updated;
    if (task.isRecurring) {
      final d = date ?? DateTime.now();
      final key = Task.dateKey(d);
      final newDateCompletions = task._copyDateCompletions();
      final dayMap = Map<String, bool>.from(
          newDateCompletions[key] ??
              {for (final id in task.memberIds) id: false});
      dayMap[memberId] = !(dayMap[memberId] ?? false);
      newDateCompletions[key] = dayMap;
      updated = task.copyWith(dateCompletions: newDateCompletions);
    } else {
      final newCompletions = Map<String, bool>.from(task.completions);
      newCompletions[memberId] = !(newCompletions[memberId] ?? false);
      updated = task.copyWith(completions: newCompletions);
    }

    await _svc.setTask(_familyId!, updated);
  }

  Future<void> toggleSubtask(String taskId, String subtaskId,
      {DateTime? date}) async {
    if (_familyId == null) return;
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final task = _tasks[idx];
    final d = date ?? DateTime.now();
    final key = task.isRecurring
        ? '${subtaskId}_${Task.dateKey(d)}'
        : subtaskId;
    final current = task.subtaskCompletions[key] ?? false;
    final newCompletions = Map<String, bool>.from(task.subtaskCompletions)
      ..[key] = !current;
    await _svc.setTask(
        _familyId!, task.copyWith(subtaskCompletions: newCompletions));
  }

  List<Task> getTasksForDate(DateTime date) =>
      _tasks.where((t) => t.appliesToDate(date)).toList();

  List<Task> getTasksForMember(String memberId) =>
      _tasks.where((t) => t.memberIds.contains(memberId)).toList();

  @override
  void dispose() {
    _membersSubscription?.cancel();
    _tasksSubscription?.cancel();
    super.dispose();
  }
}

extension _TaskCopy on Task {
  Map<String, Map<String, bool>> _copyDateCompletions() =>
      dateCompletions.map((k, v) => MapEntry(k, Map<String, bool>.from(v)));
}
