import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart' as ap;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegister  = false;
  bool _loading     = false;
  bool _obscurePass = true;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('📅', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                  ),
                  Text(
                    'Family Task Manager',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 40),

                  if (!kIsWeb) ...[
                    FilledButton.icon(
                      onPressed: _loading ? null : _signInGoogle,
                      icon: const Text('G',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      label: Text(l.signInWithGoogle),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(
                            color: cs.outline.withValues(alpha: 0.4)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l.emailLabel,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || !v.contains('@'))
                                  ? 'Enter a valid email'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            labelText: l.passwordLabel,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'At least 6 characters'
                              : null,
                        ),

                        if (!_isRegister)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero),
                              child: Text(l.forgotPassword),
                            ),
                          ),

                        if (_error != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _error!,
                            style: TextStyle(color: cs.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loading ? null : _submitEmail,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : Text(_isRegister ? l.createAccount : l.signIn),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      _isRegister = !_isRegister;
                      _error = null;
                    }),
                    child: Text(_isRegister
                        ? l.alreadyHaveAccount
                        : l.noAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInGoogle() async {
    setState(() { _loading = true; _error = null; });
    final err = await context.read<ap.AuthProvider>().signInWithGoogle();
    if (mounted) setState(() { _loading = false; _error = err; });
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final auth = context.read<ap.AuthProvider>();
    final err = _isRegister
        ? await auth.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text)
        : await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) setState(() { _loading = false; _error = err; });
  }

  Future<void> _forgotPassword() async {
    final l = AppLocalizations.of(context)!;
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());

    final submitted = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.forgotPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email and we'll send a reset link."),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.emailLabel,
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, emailCtrl.text.trim()),
            child: Text(l.sendResetLink),
          ),
        ],
      ),
    );

    emailCtrl.dispose();
    if (submitted == null || submitted.isEmpty || !mounted) return;

    final err = await context.read<ap.AuthProvider>().sendPasswordReset(submitted);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Reset link sent! Check your email.'),
      backgroundColor: err == null
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.error,
    ));
  }
}
