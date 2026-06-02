import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/family_member.dart';

class AgentMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  AgentMessage({required this.role, required this.content});
}

class AgentAction {
  final String type; // 'add_task'
  final Map<String, dynamic> params;
  AgentAction({required this.type, required this.params});
}

class AgentResult {
  final String reply;
  final List<AgentAction> actions;
  AgentResult({required this.reply, this.actions = const []});
}

class AgentService {
  static const _endpoint = 'https://api.anthropic.com/v1/messages';
  static const _model    = 'claude-3-5-haiku-20241022';

  final String apiKey;
  AgentService({required this.apiKey});

  Future<AgentResult> send({
    required List<AgentMessage> history,
    required List<FamilyMember> members,
    required List<Task> tasks,
    required DateTime today,
  }) async {
    final systemPrompt = _buildSystem(members, tasks, today);
    final messages = history
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(err['error']?['message'] ?? 'API error ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = (data['content'] as List).first['text'] as String;

    // Try to parse any JSON action blocks the model returns
    final actions = <AgentAction>[];
    final actionRegex = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```');
    for (final match in actionRegex.allMatches(text)) {
      try {
        final json = jsonDecode(match.group(1)!) as Map<String, dynamic>;
        if (json.containsKey('action')) {
          actions.add(AgentAction(
            type: json['action'] as String,
            params: json['params'] as Map<String, dynamic>? ?? {},
          ));
        }
      } catch (_) {}
    }

    // Strip the JSON blocks from the visible reply
    final reply = text.replaceAll(actionRegex, '').trim();
    return AgentResult(reply: reply, actions: actions);
  }

  String _buildSystem(
    List<FamilyMember> members,
    List<Task> tasks,
    DateTime today,
  ) {
    final memberList = members
        .map((m) =>
            '  - ${m.emoji} ${m.name} (id: ${m.id}, role: ${m.isParent ? "parent" : "child"})')
        .join('\n');

    final taskList = tasks.take(30).map((t) {
      final assignees = members
          .where((m) => t.memberIds.contains(m.id))
          .map((m) => m.name)
          .join(', ');
      final recurrence = t.isRecurring ? ' [${t.recurrence.name}]' : '';
      return '  - "${t.title}"$recurrence → assigned to: ${assignees.isEmpty ? "nobody" : assignees}';
    }).join('\n');

    return '''
You are a friendly family assistant for the MyDays app.
Today is ${today.toIso8601String().substring(0, 10)}.

FAMILY MEMBERS:
$memberList

CURRENT TASKS (up to 30):
${taskList.isEmpty ? "  (none yet)" : taskList}

You can help by:
- Answering questions about schedules and tasks
- Creating new tasks when asked

When the user asks to CREATE a task, reply naturally AND include a JSON action block like:
```json
{"action":"add_task","params":{"title":"...","description":"...","memberNames":["Name1"],"recurrence":"none|daily|weekdays|weekly","customDates":["YYYY-MM-DD"]}}
```

Rules for the JSON block:
- "recurrence" must be one of: none, daily, weekdays, weekly
- If recurrence is "none", include "customDates" (array of ISO date strings the task applies to)
- If recurrence is not "none", omit "customDates"
- "memberNames" must match names from the family list above
- Keep title short and clear

Do NOT include the JSON block for any other request — only when creating a task.
Always be warm, concise, and supportive. Use the family members\' names naturally.
''';
  }
}
