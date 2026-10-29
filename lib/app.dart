import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routing/app_router.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/tracker/view_models/tracker_view_model.dart';

/// Root `MaterialApp.router` widget binding theme mode and declarative routes.
class JamalsAddictionApp extends StatelessWidget {
  const JamalsAddictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.watch<TrackerViewModel>();

    return MaterialApp.router(
      title: "Jamal's Addiction",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: viewModel.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
