import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Account ───────────────────────────────────────────────────
          const _SectionHeader(label: 'Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Signed in as'),
            subtitle: Text(auth.user?.email ?? auth.user?.uid ?? '—'),
          ),
          ListTile(
            leading: Icon(auth.isParent
                ? Icons.admin_panel_settings_outlined
                : Icons.child_care_outlined),
            title: const Text('Role'),
            subtitle: Text(auth.isParent ? 'Parent (admin)' : 'Child'),
          ),

          // ── Family (parents only) ─────────────────────────────────────
          if (auth.isParent) ...[
            const _SectionHeader(label: 'Family'),
            _InviteCodeTile(familyId: auth.familyId!),
            SwitchListTile(
              secondary: const Icon(Icons.add_task_outlined),
              title: const Text('Children can add tasks'),
              subtitle: const Text('When off, only parents can create tasks'),
              value: auth.allowChildAddTasks,
              onChanged: (v) => auth.updateAllowChildAddTasks(v),
            ),
          ],

          // ── Appearance ────────────────────────────────────────────────
          const _SectionHeader(label: 'Appearance'),
          const _AppearanceSection(),

          // ── Language ──────────────────────────────────────────────────
          const _SectionHeader(label: 'Language'),
          const _LanguageSection(),

          // ── Session ───────────────────────────────────────────────────
          const _SectionHeader(label: 'Session'),
          ListTile(
            leading: Icon(Icons.logout, color: errorColor),
            title: Text('Sign out', style: TextStyle(color: errorColor)),
            onTap: () => _confirmSignOut(context, auth),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, ap.AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need to sign in again to access your family data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await auth.signOut();
    }
  }
}

// ── Language section ───────────────────────────────────────────────────────

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: LocaleProvider.supportedLocales.map((locale) {
          final selected = localeProv.locale.languageCode == locale.languageCode;
          final name = LocaleProvider.languageNames[locale.languageCode] ?? locale.languageCode;
          return GestureDetector(
            onTap: () => localeProv.setLocale(locale),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? cs.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Appearance section ─────────────────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final members   = context.watch<AppProvider>().members;
    final cs        = Theme.of(context).colorScheme;

    final memberThemes = members
        .map((m) => AppTheme(
              id: 'member_${m.id}',
              name: m.name,
              colorValue: m.colorValue,
              emoji: m.emoji,
            ))
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dark / Light toggle
          Row(
            children: [
              Icon(Icons.light_mode_outlined, size: 18,
                  color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('Light', style: TextStyle(color: cs.onSurfaceVariant)),
              Switch(value: themeProv.isDark, onChanged: themeProv.setDark),
              Text('Dark', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(width: 6),
              Icon(Icons.dark_mode_outlined, size: 18,
                  color: cs.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 14),

          // Built-in themes
          Text('Themes',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: builtinThemes
                .map((t) => _ThemeSwatch(
                      theme: t,
                      selected: themeProv.colorValue == t.colorValue,
                      onTap: () => themeProv.setColor(t.colorValue),
                    ))
                .toList(),
          ),

          // Member-inspired themes
          if (memberThemes.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Family colours',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: memberThemes
                  .map((t) => _ThemeSwatch(
                        theme: t,
                        selected: themeProv.colorValue == t.colorValue,
                        onTap: () => themeProv.setColor(t.colorValue),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = theme.color;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: theme.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )]
                    : [],
              ),
              child: Center(
                child: theme.emoji != null
                    ? Text(theme.emoji!, style: const TextStyle(fontSize: 24))
                    : selected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _InviteCodeTile extends StatelessWidget {
  final String familyId;
  const _InviteCodeTile({required this.familyId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseService().watchFamily(familyId).first,
      builder: (context, snap) {
        final code = snap.data?.inviteCode ?? '——————';
        return ListTile(
          leading: const Icon(Icons.qr_code_outlined),
          title: const Text('Invite code'),
          subtitle: Text(
            code,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied!')),
              );
            },
          ),
        );
      },
    );
  }
}
