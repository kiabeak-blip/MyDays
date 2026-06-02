import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../models/family_member.dart';
import '../services/firebase_service.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<ap.AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Setup'),
        actions: [
          TextButton(
            onPressed: auth.signOut,
            child: const Text('Sign out'),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Create Family'),
            Tab(text: 'Join Family'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CreateFamilyTab(),
          _JoinFamilyTab(),
        ],
      ),
    );
  }
}

// ── Create Family ─────────────────────────────────────────────────────────────

class _CreateFamilyTab extends StatefulWidget {
  const _CreateFamilyTab();

  @override
  State<_CreateFamilyTab> createState() => _CreateFamilyTabState();
}

class _CreateFamilyTabState extends State<_CreateFamilyTab> {
  static const _colors = [
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFF7043),
    Color(0xFFEC407A),
  ];
  static const _emojis = ['👨', '👩', '🧔', '👱', '🧕', '🧑'];

  final _familyNameCtrl = TextEditingController();
  final _myNameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String _emoji = '👨';
  int _colorValue = 0xFF5C6BC0;

  @override
  void dispose() {
    _familyNameCtrl.dispose();
    _myNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = Color(_colorValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create a new family',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "You'll be the family admin. Your family members join using an invite code.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _familyNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Family name',
              hintText: 'e.g. The Mohammed Family',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          Text('Your profile', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          // Avatar preview + emoji/color pickers
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color,
                child: Text(_emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: _emojis
                          .map((e) => GestureDetector(
                                onTap: () => setState(() => _emoji = e),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _emoji == e
                                      ? cs.primaryContainer
                                      : cs.surfaceContainerHighest,
                                  child: Text(e,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _colors
                          .map((c) => GestureDetector(
                                onTap: () =>
                                    setState(() => _colorValue = c.toARGB32()),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: c,
                                  child: _colorValue == c.toARGB32()
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _myNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Your name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _create,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Create Family'),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final familyName = _familyNameCtrl.text.trim();
    final myName = _myNameCtrl.text.trim();
    if (familyName.isEmpty || myName.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await context.read<ap.AuthProvider>().createFamily(
          familyName,
          parentName: myName,
          parentEmoji: _emoji,
          parentColorValue: _colorValue,
        );
    if (mounted) setState(() { _loading = false; _error = err; });
  }
}

// ── Join Family ───────────────────────────────────────────────────────────────

class _JoinFamilyTab extends StatefulWidget {
  const _JoinFamilyTab();

  @override
  State<_JoinFamilyTab> createState() => _JoinFamilyTabState();
}

class _JoinFamilyTabState extends State<_JoinFamilyTab> {
  final _codeCtrl = TextEditingController();
  final _svc = FirebaseService();
  bool _loading = false;
  bool _lookingUp = false;
  String? _error;
  List<FamilyMember>? _availableMembers;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Join an existing family',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Ask the family admin for the 6-character invite code.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Invite code',
                    hintText: 'ABC123',
                    prefixIcon: Icon(Icons.key_outlined),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FilledButton(
                  onPressed: _lookingUp ? null : _lookupCode,
                  child: _lookingUp
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Look up'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: cs.error)),
          ],
          if (_availableMembers != null) ...[
            const SizedBox(height: 24),
            Text('Select your profile:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_availableMembers!.isEmpty)
              Text(
                'No available profiles — ask the family admin to add one for you first.',
                style: TextStyle(color: cs.onSurfaceVariant),
              )
            else
              ..._availableMembers!.map(
                (m) => _MemberTile(
                  member: m,
                  loading: _loading,
                  onJoin: () => _join(m.id),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _lookupCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 6) {
      setState(() => _error = 'Enter the full 6-character code');
      return;
    }
    setState(() { _lookingUp = true; _error = null; _availableMembers = null; });

    final settings = await _svc.findFamilyByCode(code);
    if (!mounted) return;
    if (settings == null) {
      setState(() { _lookingUp = false; _error = 'Code not found. Check with your admin.'; });
      return;
    }

    final available = await _svc.getAvailableMembers(settings.familyId);
    if (!mounted) return;
    setState(() { _lookingUp = false; _availableMembers = available; });
  }

  Future<void> _join(String memberId) async {
    setState(() { _loading = true; _error = null; });
    final code = _codeCtrl.text.trim().toUpperCase();
    final err = await context.read<ap.AuthProvider>().joinFamily(code, memberId);
    if (mounted) setState(() { _loading = false; _error = err; });
  }
}

class _MemberTile extends StatelessWidget {
  final FamilyMember member;
  final bool loading;
  final VoidCallback onJoin;

  const _MemberTile({
    required this.member,
    required this.loading,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(member.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(member.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(member.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: FilledButton(
          onPressed: loading ? null : onJoin,
          child: const Text('This is me'),
        ),
      ),
    );
  }
}
