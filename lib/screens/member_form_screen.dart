import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_member.dart';
import '../providers/app_provider.dart';

class MemberFormScreen extends StatefulWidget {
  final FamilyMember? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  static const _colors = [
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFFF7043),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF78909C),
    Color(0xFF8D6E63),
  ];

  static const _emojis = [
    '👨', '👩', '👦', '👧', '👴', '👵',
    '🧑', '👶', '🧒', '🧔', '👱', '🧕',
    '🦸', '🧙', '🐶', '🐱', '🦊', '🐻',
    '🌟', '🎯', '🚀', '🎸', '⚽', '🎨',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late int _selectedColorValue;
  late String _selectedEmoji;
  late MemberRole _selectedRole;

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _selectedColorValue = m?.colorValue ?? _colors[0].toARGB32();
    _selectedEmoji = m?.emoji ?? '👤';
    _selectedRole = m?.role ?? MemberRole.child;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Member' : 'Add Member'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove member',
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickEmoji,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(_selectedColorValue),
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: cs.surface,
                      child: Icon(Icons.edit, size: 16, color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 24),
            Text('Role', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<MemberRole>(
              segments: const [
                ButtonSegment(
                  value: MemberRole.child,
                  icon: Icon(Icons.child_care_outlined),
                  label: Text('Child'),
                ),
                ButtonSegment(
                  value: MemberRole.parent,
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  label: Text('Parent'),
                ),
              ],
              selected: {_selectedRole},
              onSelectionChanged: (s) =>
                  setState(() => _selectedRole = s.first),
            ),
            const SizedBox(height: 24),
            Text('Colour', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final selected = color.toARGB32() == _selectedColorValue;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColorValue = color.toARGB32()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: cs.onSurface, width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 22)
                        : null,
                  ),
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
            onPressed: _save,
            child: Text(_isEditing ? 'Save Changes' : 'Add Member'),
          ),
        ),
      ),
    );
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose avatar',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _emojis.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmoji = _emojis[i]);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedEmoji == _emojis[i]
                          ? Theme.of(ctx).colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(_emojis[i], style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();

    if (_isEditing) {
      await provider.updateMember(widget.member!.copyWith(
        name: _nameCtrl.text.trim(),
        colorValue: _selectedColorValue,
        emoji: _selectedEmoji,
        role: _selectedRole,
      ));
    } else {
      await provider.addMember(
        _nameCtrl.text.trim(),
        _selectedColorValue,
        _selectedEmoji,
        role: _selectedRole,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
            '${widget.member!.name} will be removed from all tasks. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final nav = Navigator.of(context);
      await context.read<AppProvider>().deleteMember(widget.member!.id);
      nav.pop();
    }
  }
}
