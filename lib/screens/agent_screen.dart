import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../services/agent_service.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final _textCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _thinking = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _messages.add(_ChatMessage(
      role: 'assistant',
      text: "Hi! I'm your family assistant 👋 I can help you manage tasks, check schedules, and create new tasks. What would you like to do?",
    ));
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _apiKey = prefs.getString('claude_api_key'));
  }

  Future<void> _saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('claude_api_key', key);
    setState(() => _apiKey = key);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.key_outlined),
            tooltip: 'Set API key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_apiKey == null || _apiKey!.isEmpty)
            _ApiKeyBanner(onSetKey: _showApiKeyDialog),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_thinking ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_thinking && i == _messages.length) {
                  return _ThinkingBubble();
                }
                return _Bubble(message: _messages[i]);
              },
            ),
          ),
          _InputBar(
            controller: _textCtrl,
            enabled: !_thinking && (_apiKey?.isNotEmpty == true),
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _thinking = true;
    });
    _scrollToBottom();

    final provider = context.read<AppProvider>();

    try {
      final service = AgentService(apiKey: _apiKey!);
      final history = _messages
          .map((m) => AgentMessage(role: m.role, content: m.text))
          .toList();

      final result = await service.send(
        history: history,
        members: provider.members,
        tasks: provider.tasks,
        today: DateTime.now(),
      );

      // Execute any actions the model returned
      for (final action in result.actions) {
        await _executeAction(action, provider);
      }

      if (mounted) {
        setState(() {
          _thinking = false;
          _messages.add(_ChatMessage(role: 'assistant', text: result.reply));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _thinking = false;
          _messages.add(_ChatMessage(
            role: 'assistant',
            text: '⚠️ Something went wrong: ${e.toString().replaceAll('Exception: ', '')}',
            isError: true,
          ));
        });
      }
    }
  }

  Future<void> _executeAction(AgentAction action, AppProvider provider) async {
    if (action.type != 'add_task') return;
    final p = action.params;

    final memberNames = List<String>.from(p['memberNames'] ?? []);
    final memberIds   = provider.members
        .where((m) => memberNames.contains(m.name))
        .map((m) => m.id)
        .toList();

    final recStr = (p['recurrence'] as String? ?? 'none').toLowerCase();
    final recurrence = RecurrenceType.values.firstWhere(
      (r) => r.name == recStr,
      orElse: () => RecurrenceType.none,
    );

    List<DateTime> customDates = [];
    if (recurrence == RecurrenceType.none) {
      final rawDates = List<String>.from(p['customDates'] ?? []);
      customDates = rawDates.map((d) => DateTime.parse(d)).toList();
      if (customDates.isEmpty) customDates = [DateTime.now()];
    }

    final refDate = customDates.isNotEmpty ? customDates.first : DateTime.now();

    await provider.addTask(
      title:       p['title'] as String? ?? 'New Task',
      description: p['description'] as String? ?? '',
      scope:       TaskScope.custom,
      recurrence:  recurrence,
      referenceDate: refDate,
      customDates: customDates,
      memberIds:   memberIds,
    );
  }

  Future<void> _showApiKeyDialog() async {
    final ctrl = TextEditingController(text: _apiKey);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anthropic API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Claude API key from console.anthropic.com. It\'s stored only on this device.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API key',
                prefixIcon: Icon(Icons.key_outlined),
                border: OutlineInputBorder(),
                hintText: 'sk-ant-...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveApiKey(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ── Chat data ─────────────────────────────────────────────────────────────

class _ChatMessage {
  final String role;
  final String text;
  final bool isError;
  final DateTime time;

  _ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
  }) : time = DateTime.now();
}

// ── Bubble widgets ────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isUser  = message.role == 'user';
    final bgColor = message.isError
        ? cs.errorContainer
        : isUser
            ? cs.primaryContainer
            : cs.surfaceContainerLow;
    final fgColor = message.isError
        ? cs.onErrorContainer
        : isUser
            ? cs.onPrimaryContainer
            : cs.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft:     const Radius.circular(16),
              topRight:    const Radius.circular(16),
              bottomLeft:  Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4  : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(message.text,
                  style: TextStyle(color: fgColor, fontSize: 14, height: 1.4)),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.time),
                style: TextStyle(
                    fontSize: 10,
                    color: fgColor.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topLeft:     Radius.circular(16),
            topRight:    Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft:  Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border:
              Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enabled ? onSend() : null,
                decoration: InputDecoration(
                  hintText: enabled
                      ? 'Ask me anything…'
                      : 'Set your API key to start',
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enabled ? onSend : null,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── API key banner ────────────────────────────────────────────────────────

class _ApiKeyBanner extends StatelessWidget {
  final VoidCallback onSetKey;
  const _ApiKeyBanner({required this.onSetKey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: cs.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add your Claude API key to enable the assistant.',
              style: TextStyle(
                  fontSize: 13, color: cs.onTertiaryContainer),
            ),
          ),
          TextButton(
            onPressed: onSetKey,
            style: TextButton.styleFrom(
                foregroundColor: cs.onTertiaryContainer),
            child: const Text('Set key'),
          ),
        ],
      ),
    );
  }
}
