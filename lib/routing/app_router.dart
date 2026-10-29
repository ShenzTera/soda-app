import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/wrapped_summary.dart';
import '../ui/features/calendar/views/soda_calendar_screen.dart';
import '../ui/features/history/views/backfill_history_screen.dart';
import '../ui/features/tracker/views/drink_zoom_sheet.dart';
import '../ui/features/tracker/views/home_screen.dart';
import '../ui/features/wrapped/views/soda_wrapped_screen.dart';

/// Declarative `GoRouter` configuration for Jamal's Addiction.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'zoom/:drinkId',
            name: 'zoom',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String drinkId =
                  state.pathParameters['drinkId'] ?? 'coke';
              return CustomTransitionPage<void>(
                key: state.pageKey,
                opaque: false,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.72),
                transitionDuration: const Duration(milliseconds: 320),
                transitionsBuilder: (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child,
                ) {
                  final CurvedAnimation curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: DrinkZoomSheet(drinkId: drinkId),
              );
            },
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                opaque: false,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.76),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: _slideUpTransition,
                child: const BackfillHistoryScreen(),
              );
            },
          ),
          GoRoute(
            path: 'calendar',
            name: 'calendar',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                opaque: false,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.78),
                transitionDuration: const Duration(milliseconds: 320),
                transitionsBuilder: _slideUpTransition,
                child: const SodaCalendarScreen(),
              );
            },
          ),
          GoRoute(
            path: 'wrapped',
            name: 'wrapped',
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String? periodParam = state.uri.queryParameters['period'];
              final WrappedPeriod initialPeriod = switch (periodParam) {
                'weekly' => WrappedPeriod.weekly,
                'monthly' => WrappedPeriod.monthly,
                _ => WrappedPeriod.yearly,
              };
              return CustomTransitionPage<void>(
                key: state.pageKey,
                opaque: false,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.85),
                transitionDuration: const Duration(milliseconds: 360),
                transitionsBuilder: _slideUpTransition,
                child: SodaWrappedScreen(initialPeriod: initialPeriod),
              );
            },
          ),
        ],
      ),
    ],
  );

  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
