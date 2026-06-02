import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/family_setup_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyDaysApp(),
    ),
  );
}

class MyDaysApp extends StatelessWidget {
  const MyDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MyDays',
      debugShowCheckedModeBanner: false,
      themeMode: themeProv.themeMode,
      theme: themeProv.buildTheme(Brightness.light),
      darkTheme: themeProv.buildTheme(Brightness.dark),
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<ap.AuthProvider>();
    final appProvider = context.read<AppProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (auth.status == ap.AuthStatus.ready && auth.familyId != null) {
        appProvider.init(auth.familyId!);
      } else if (auth.status == ap.AuthStatus.unauthenticated) {
        appProvider.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();

    return switch (auth.status) {
      ap.AuthStatus.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ap.AuthStatus.unauthenticated => const AuthScreen(key: ValueKey('auth')),
      ap.AuthStatus.noFamily => const FamilySetupScreen(key: ValueKey('setup')),
      ap.AuthStatus.ready => const MainScreen(key: ValueKey('main')),
    };
  }
}
