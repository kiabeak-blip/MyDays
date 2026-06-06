import 'dart:convert';
import 'subtask.dart';

export 'subtask.dart';

enum TaskScope { day, week, month, custom }

enum RecurrenceType { none, daily, everyOtherDay, weekdays, weekly }

class Task {
  final String id;
  final String title;
  final String description;
  final String iconEmoji; // visual icon for young children
  final List<SubTask> subtasks; // checklist items inside the task
  final TaskScope scope;
  final RecurrenceType recurrence;
  final DateTime referenceDate;
  final List<DateTime> customDates;
  final List<String> memberIds;
  final Map<String, bool> completions;
  final Map<String, Map<String, bool>> dateCompletions;
  // subtaskCompletions: key = subtaskId (one-time) or subtaskId_YYYY-MM-DD (recurring)
  final Map<String, bool> subtaskCompletions;
  final DateTime createdAt;
  final DateTime? endDate; // recurring tasks only — stops after this date

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.iconEmoji = '',
    this.subtasks = const [],
    required this.scope,
    this.recurrence = RecurrenceType.none,
    required this.referenceDate,
    this.customDates = const [],
    required this.memberIds,
    required this.completions,
    this.dateCompletions = const {},
    this.subtaskCompletions = const {},
    required this.createdAt,
    this.endDate,
  });

  bool get isRecurring => recurrence != RecurrenceType.none;

  bool appliesToDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);

    if (isRecurring) {
      final start =
          DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
      if (d.isBefore(start)) return false;
      if (endDate != null) {
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        if (d.isAfter(end)) return false;
      }
      switch (recurrence) {
        case RecurrenceType.none:
          break;
        case RecurrenceType.daily:
          return true;
        case RecurrenceType.everyOtherDay:
          return d.difference(start).inDays % 2 == 0;
        case RecurrenceType.weekdays:
          return d.weekday >= DateTime.monday &&
              d.weekday <= DateTime.friday;
        case RecurrenceType.weekly:
          return d.weekday == start.weekday;
      }
    }

    switch (scope) {
      case TaskScope.day:
        final ref = DateTime(
            referenceDate.year, referenceDate.month, referenceDate.day);
        return d == ref;
      case TaskScope.week:
        final ws = weekStart(referenceDate);
        final we = ws.add(const Duration(days: 6));
        return !d.isBefore(ws) && !d.isAfter(we);
      case TaskScope.month:
        return d.year == referenceDate.year && d.month == referenceDate.month;
      case TaskScope.custom:
        return customDates
            .any((cd) => DateTime(cd.year, cd.month, cd.day) == d);
    }
  }

  Map<String, bool> completionsForDate(DateTime date) {
    if (!isRecurring) return completions;
    final key = dateKey(date);
    return dateCompletions[key] ??
        {for (final id in memberIds) id: false};
  }

  bool isFullyCompleteForDate(DateTime date) {
    final c = completionsForDate(date);
    return memberIds.isNotEmpty && memberIds.every((id) => c[id] == true);
  }

  int completedCountForDate(DateTime date) {
    final c = completionsForDate(date);
    return memberIds.where((id) => c[id] == true).length;
  }

  bool get isFullyComplete =>
      memberIds.isNotEmpty &&
      memberIds.every((id) => completions[id] == true);

  int get completedCount =>
      memberIds.where((id) => completions[id] == true).length;

  // Per-date subtask helpers
  String _subtaskKey(String subtaskId, DateTime date) =>
      isRecurring ? '${subtaskId}_${dateKey(date)}' : subtaskId;

  bool isSubtaskDoneForDate(String subtaskId, DateTime date) =>
      subtaskCompletions[_subtaskKey(subtaskId, date)] ?? false;

  int subtasksDoneCountForDate(DateTime date) =>
      subtasks.where((s) => isSubtaskDoneForDate(s.id, date)).length;

  // Legacy (kept for backward compat)
  int get subtaskDoneCount => subtasks.where((s) => s.completed).length;

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime weekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime weekEnd(DateTime date) =>
      weekStart(date).add(const Duration(days: 6));

  Task copyWith({
    String? title,
    String? description,
    String? iconEmoji,
    List<SubTask>? subtasks,
    TaskScope? scope,
    RecurrenceType? recurrence,
    DateTime? referenceDate,
    List<DateTime>? customDates,
    List<String>? memberIds,
    Map<String, bool>? completions,
    Map<String, Map<String, bool>>? dateCompletions,
    Map<String, bool>? subtaskCompletions,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      subtasks: subtasks ?? List.from(this.subtasks),
      scope: scope ?? this.scope,
      recurrence: recurrence ?? this.recurrence,
      referenceDate: referenceDate ?? this.referenceDate,
      customDates: customDates ?? List.from(this.customDates),
      memberIds: memberIds ?? List.from(this.memberIds),
      completions: completions ?? Map.from(this.completions),
      dateCompletions: dateCompletions ?? _copyDateCompletions(),
      subtaskCompletions: subtaskCompletions ?? Map.from(this.subtaskCompletions),
      createdAt: createdAt,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  Map<String, Map<String, bool>> _copyDateCompletions() =>
      dateCompletions.map((k, v) => MapEntry(k, Map<String, bool>.from(v)));

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconEmoji': iconEmoji,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'scope': scope.name,
        'recurrence': recurrence.name,
        'referenceDate': referenceDate.toIso8601String(),
        'customDates': customDates.map((d) => d.toIso8601String()).toList(),
        'memberIds': memberIds,
        'completions': completions,
        'dateCompletions': dateCompletions,
        'subtaskCompletions': subtaskCompletions,
        'createdAt': createdAt.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        iconEmoji: json['iconEmoji'] as String? ?? '',
        subtasks: (json['subtasks'] as List? ?? [])
            .map((s) => SubTask.fromJson(s as Map<String, dynamic>))
            .toList(),
        scope: TaskScope.values.firstWhere(
          (s) => s.name == json['scope'],
          orElse: () => TaskScope.day,
        ),
        recurrence: RecurrenceType.values.firstWhere(
          (r) => r.name == json['recurrence'],
          orElse: () => RecurrenceType.none,
        ),
        referenceDate: DateTime.parse(json['referenceDate'] as String),
        customDates: (json['customDates'] as List? ?? [])
            .map((d) => DateTime.parse(d as String))
            .toList(),
        memberIds: List<String>.from(json['memberIds'] as List),
        completions: Map<String, bool>.from(
          (json['completions'] as Map).map(
            (k, v) => MapEntry(k as String, v as bool),
          ),
        ),
        subtaskCompletions: Map<String, bool>.from(
          (json['subtaskCompletions'] as Map? ?? {}).map(
            (k, v) => MapEntry(k as String, v as bool),
          ),
        ),
        dateCompletions: (json['dateCompletions'] as Map? ?? {}).map(
          (k, v) => MapEntry(
            k as String,
            Map<String, bool>.from(
              (v as Map).map((mk, mv) => MapEntry(mk as String, mv as bool)),
            ),
          ),
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
      );

  static String encode(List<Task> tasks) =>
      jsonEncode(tasks.map((t) => t.toJson()).toList());

  static List<Task> decode(String source) =>
      (jsonDecode(source) as List)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList();
}
