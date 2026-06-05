import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Members',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Assistant',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'My Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Assistant',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
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
