import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'neomorphic/neumorphic_container.dart';
import '../../features/chat/providers/career_pilot_provider.dart';
import '../providers/database_provider.dart';
import '../providers/drawer_provider.dart';
import '../providers/ui_state_provider.dart';
import '../providers/wellbeing_provider.dart';
import '../../features/zen/providers/zen_provider.dart';
import '../../features/zen/zen_sanctuary_screen.dart';
import '../../features/zen/zen_shield_checklist_screen.dart';

/**
 * The root navigation scaffold for CareerOS.
 * Provides the global sidebar, floating glass navigation bar,
 * and handles the Zen Mode full-screen takeover logic.
 */
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zen = ref.watch(zenProvider);

    // 1. ZEN MODE LOCK (Sovereign Takeover)
    if (zen.isActive) {
      return const ZenSanctuaryScreen();
    }

    final isNavBarVisible = ref.watch(isNavBarVisibleProvider);

    return Scaffold(
      key: ref.watch(scaffoldKeyProvider),
      extendBody: true,
      drawer: _CareerOSDrawer(navigationShell: navigationShell),
      body: navigationShell,
      bottomNavigationBar: _AnimatedNavBar(
        isVisible: isNavBarVisible,
        child: _GlassBottomBar(navigationShell: navigationShell),
      ),
    );
  }
}

/**
 * A wrapper to handle smooth visibility transitions for the navigation bar.
 */
class _AnimatedNavBar extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  const _AnimatedNavBar({required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: isVisible ? child : const SizedBox.shrink(),
    );
  }
}

/**
 * The Global Career Sidebar.
 * Organized into logical segments: Session Control, History, and Focus.
 */
class _CareerOSDrawer extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const _CareerOSDrawer({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pilot = ref.watch(careerPilotProvider.notifier);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.05), height: 1),
              ),

              _buildSectionTitle("DEEP FOCUS", theme),
              _DrawerItem(
                icon: Icons.spa_outlined,
                label: 'Enter Zen Sanctuary',
                onTap: () {
                  final zenNotifier = ref.read(zenProvider.notifier);
                  Navigator.of(context).pop();
                  _showZenEntryDialog(context, zenNotifier);
                },
              ),
              _DrawerItem(
                icon: Icons.auto_stories_outlined,
                label: 'Scholar Stream',
                onTap: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/scholar_stream');
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ),

              _buildSectionTitle("AI CO-PILOT SESSIONS", theme),
              _DrawerItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'New Normal Chat',
                onTap: () {
                  Navigator.of(context).pop();
                  pilot.startNormalChat();
                },
              ),
              _DrawerItem(
                icon: Icons.psychology_outlined,
                label: 'Deep Career Counseling',
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmResetCounseling(context, pilot);
                },
              ),
              _DrawerItem(
                icon: Icons.delete_sweep_outlined,
                label: 'Clear Chat History',
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmClearChat(context, pilot);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Divider(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ),

              _buildSectionTitle("VOYAGE METRICS", theme),
              _DrawerItem(
                icon: Icons.history_outlined,
                label: 'Career Milestones',
                onTap: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/history');
                },
              ),
              _DrawerItem(
                icon: Icons.calendar_today_rounded,
                label: 'Lifetime Voyage Log',
                onTap: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/lifetime_calendar');
                },
              ),
              _DrawerItem(
                icon: Icons.forum_outlined,
                label: 'Full Chat History',
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push('/chat_history');
                },
              ),

              const SizedBox(height: 60),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CareerOS',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1.5,
            ),
          ),
          Text(
            'Sovereign Navigation System',
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        'VERSION 2.5.5 | SUPREME EDITION',
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.12), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }

  void _confirmClearChat(BuildContext context, CareerPilotNotifier pilot) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
        title: Text('Purge History?',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900)),
        content: Text('This will permanently delete the current conversation logs.',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('CANCEL',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.24)))),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              pilot.startNormalChat().then((_) => navigationShell.goBranch(0));
            },
            child: const Text('CONFIRM PURGE',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmResetCounseling(BuildContext context, CareerPilotNotifier pilot) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
        title: Text('Full Reset?',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w900)),
        content: Text('This resets your entire career profile and discovery journey.',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.54),
                fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('CANCEL',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.24)))),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              pilot.startDeepCounseling();
            },
            child: const Text('ENGAGE RESET',
                style: TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showZenEntryDialog(BuildContext context, ZenNotifier zenNotifier) {
    int selectedMinutes = 30;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1))),
          title: Text("ZEN SANCTUARY",
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select duration for deep sea focus.",
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.38),
                      fontSize: 12)),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [30, 60, 120, 180].map((m) => ChoiceChip(
                  label: Text("$m min"),
                  selected: selectedMinutes == m,
                  onSelected: (s) => setDialogState(() => selectedMinutes = m),
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.02),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: selectedMinutes == m ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.24), fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("ABORT",
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.12)))),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => ZenShieldChecklistScreen(minutes: selectedMinutes, task: "Deep Study Voyage")));
              },
              child: Text("INITIALIZE", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 22),
        title: Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w400)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
        hoverColor: theme.colorScheme.onSurface.withOpacity(0.02),
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: NeumorphicContainer(
          borderRadius: 35,
          depth: 8,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final icons = [
                  Icons.home_filled,
                  Icons.forum_rounded,
                  Icons.explore_rounded,
                  Icons.health_and_safety_rounded,
                  Icons.person_3_rounded
                ];
                return _NavBarIcon(
                  icon: icons[index],
                  isSelected: navigationShell.currentIndex == index,
                  onTap: () => navigationShell.goBranch(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarIcon({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: NeumorphicContainer(
          shape: BoxShape.circle,
          depth: isSelected ? 2 : 4,
          isPressed: isSelected,
          baseColor: isSelected ? Colors.cyanAccent.withOpacity(0.05) : const Color(0xFF1A1A1A),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isSelected ? Colors.cyanAccent : Colors.white24,
            size: 24,
          ),
        ),
      ),
    );
  }
}
