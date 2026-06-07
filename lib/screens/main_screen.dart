import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/app_provider.dart';
import 'agent_screen.dart';
import 'calendar_screen.dart';
import 'member_tasks_screen.dart';
import 'members_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final provider = context.watch<AppProvider>();
    final isParent = auth.isParent;
    final l = AppLocalizations.of(context)!;

    // Find current member for the My Tasks tab
    final currentMember = auth.memberId != null
        ? provider.members.where((m) => m.id == auth.memberId).firstOrNull
        : null;

    if (isParent) {
      // Parents: Calendar | Members | Assistant | Settings
      final screens = const [
        CalendarScreen(),
        MembersScreen(),
        AgentScreen(),
        SettingsScreen(),
      ];

      return Scaffold(
        body: screens[_index.clamp(0, screens.length - 1)],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index.clamp(0, screens.length - 1),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l.navMembers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: l.navAssistant,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.navSettings,
            ),
          ],
        ),
      );
    } else {
      // Kids: Calendar | My Tasks | Assistant | Settings
      final screens = [
        const CalendarScreen(),
        if (currentMember != null)
          MemberTasksScreen(member: currentMember)
        else
          const _NoMemberPlaceholder(),
        const AgentScreen(),
        const SettingsScreen(),
      ];

      return Scaffold(
        body: screens[_index.clamp(0, screens.length - 1)],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index.clamp(0, screens.length - 1),
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.checklist_outlined),
              selectedIcon: const Icon(Icons.checklist),
              label: l.navMyTasks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: l.navAssistant,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.navSettings,
            ),
          ],
        ),
      );
    }
  }
}

class _NoMemberPlaceholder extends StatelessWidget {
  const _NoMemberPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loading your tasks…'),
      ),
    );
  }
}
