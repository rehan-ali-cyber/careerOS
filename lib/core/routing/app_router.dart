import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/roadmap/roadmap_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/history/chat_history_screen.dart';
import '../../features/calendar/lifetime_calendar_screen.dart';
import '../../features/scholar_stream/scholar_stream_screen.dart';
import '../../features/digital_wellbeing/wellbeing_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../core/persistence/preferences_service.dart';
import '../widgets/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorChatKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _shellNavigatorRoadmapKey = GlobalKey<NavigatorState>(debugLabel: 'roadmap');
final _shellNavigatorProgressKey = GlobalKey<NavigatorState>(debugLabel: 'progress');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  redirect: (context, state) {
    final onboardingCompleted = PreferencesService.isOnboardingCompleted();
    if (!onboardingCompleted && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorChatKey,
          routes: [
            GoRoute(
              path: '/chat',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorRoadmapKey,
          routes: [
            GoRoute(
              path: '/roadmap',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RoadmapScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProgressKey,
          routes: [
            GoRoute(
              path: '/wellbeing',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WellbeingScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/chat_history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChatHistoryScreen(),
    ),
    GoRoute(
      path: '/lifetime_calendar',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LifetimeCalendarScreen(),
    ),
    GoRoute(
      path: '/scholar_stream',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScholarStreamScreen(),
    ),
    GoRoute(
      path: '/progress',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProgressScreen(),
    ),
  ],
);
