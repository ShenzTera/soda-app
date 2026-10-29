import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../view_models/tracker_view_model.dart';
import '../views/reset_confirm_dialog.dart';
import 'widgets/accordion_drink_slice.dart';
import 'widgets/equivalence_tracker_dock.dart';
import 'widgets/glass_header_bar.dart';

/// Full-viewport 3-slice accordion home screen for Jamal's Addiction.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _dragStartX = 0;

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragEnd(
    DragEndDetails details,
    TrackerViewModel viewModel,
  ) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 260) {
      if (velocity < 0) {
        viewModel.selectDrinkByDelta(1);
      } else {
        viewModel.selectDrinkByDelta(-1);
      }
      return;
    }
    // Check drag distance fallback
    final double deltaX = details.localPosition.dx - _dragStartX;
    if (deltaX.abs() > 64) {
      if (deltaX < 0) {
        viewModel.selectDrinkByDelta(1);
      } else {
        viewModel.selectDrinkByDelta(-1);
      }
    }
  }

  Future<void> _showQuickToast(
    BuildContext context,
    String message,
    Color dotColor,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1600),
        margin: const EdgeInsets.only(bottom: 92, left: 24, right: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: dotColor, blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.watch<TrackerViewModel>();
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final bool isCompact = screenSize.width < 640;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _handleHorizontalDragStart,
        onHorizontalDragEnd: (DragEndDetails d) =>
            _handleHorizontalDragEnd(d, viewModel),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Full-bleed 3-slice expanding accordion showcase
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double totalWidth = constraints.maxWidth;
                // Expanded panel gets ~72% on mobile, ~68% on tablet/desktop;
                // each collapsed strip gets half of the remainder.
                final double expandedRatio = isCompact ? 0.74 : 0.68;
                final double collapsedRatio = (1.0 - expandedRatio) / 2.0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: DrinkSpec.all.map((DrinkSpec spec) {
                    final bool isActive = viewModel.activeDrinkId == spec.id;
                    final double targetWidth = totalWidth *
                        (isActive ? expandedRatio : collapsedRatio);
                    final DrinkStats todayStats =
                        viewModel.todayStatsFor(spec.id);
                    final DrinkStats lifeStats =
                        viewModel.lifetimeStatsFor(spec.id);
                    final bool pulseTrigger =
                        viewModel.lastLoggedDrinkId == spec.id;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.fastOutSlowIn,
                      width: targetWidth,
                      child: AccordionDrinkSlice(
                        spec: spec,
                        isExpanded: isActive,
                        selectedSize: viewModel.selectedSize,
                        todayStats: todayStats,
                        lifetimeStats: lifeStats,
                        pulseTick:
                            pulseTrigger ? viewModel.lastLogPulseTick : 0,
                        topInset: safePadding.top + 108,
                        bottomInset: safePadding.bottom + 102,
                        onTapCollapsed: () => viewModel.selectDrink(spec.id),
                        onIncrement: () async {
                          final entry = await viewModel.logDrink(spec.id);
                          if (context.mounted) {
                            await _showQuickToast(
                              context,
                              'Logged +1 ${spec.name} (${viewModel.selectedSize.label}) · ${DrinkStats.formatVolume(entry.ml)}',
                              spec.accentColor,
                            );
                          }
                        },
                        onDecrement: () async {
                          final removed =
                              await viewModel.removeDrinkToday(spec.id);
                          if (context.mounted) {
                            if (removed != null) {
                              await _showQuickToast(
                                context,
                                'Removed 1 ${spec.name} (${DrinkStats.formatVolume(removed.ml)}) from today',
                                spec.accentColor,
                              );
                            } else {
                              await _showQuickToast(
                                context,
                                'No ${spec.name} logged today to remove',
                                Colors.white54,
                              );
                            }
                          }
                        },
                        onOpenZoom: () => context.push('/zoom/${spec.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Top floating glassmorphic navigation & portion bar
            Positioned(
              top: safePadding.top + 8,
              left: 10,
              right: 10,
              child: GlassHeaderBar(
                totalToday: viewModel.totalTodayStats,
                totalLifetime: viewModel.totalLifetimeStats,
                selectedSize: viewModel.selectedSize,
                canUndo: viewModel.canUndo,
                onSelectSize: viewModel.selectSize,
                onUndo: () async {
                  final undone = await viewModel.undoLastTodayLog();
                  if (context.mounted && undone != null) {
                    final DrinkSpec spec = DrinkSpec.byId(undone.drinkId);
                    await _showQuickToast(
                      context,
                      'Undid ${spec.name} (${DrinkStats.formatVolume(undone.ml)})',
                      spec.accentColor,
                    );
                  }
                },
                onOpenHistory: () => context.push('/history'),
                onOpenCalendar: () => context.push('/calendar'),
                onOpenWrapped: () => context.push('/wrapped'),
                onOpenReset: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const ResetConfirmDialog(),
                  );
                },
              ),
            ),

            // Bottom floating Cans & Bottles Equivalence Tracker dock
            Positioned(
              left: 10,
              right: 10,
              bottom: safePadding.bottom + 8,
              child: EquivalenceTrackerDock(
                activeDrinkId: viewModel.activeDrinkId,
                cokeStats: viewModel.lifetimeStatsFor('coke'),
                pepsiStats: viewModel.lifetimeStatsFor('pepsi'),
                dewStats: viewModel.lifetimeStatsFor('dew'),
                totalStats: viewModel.totalLifetimeStats,
                onSelectDrink: viewModel.selectDrink,
                onOpenAllZoom: () =>
                    context.push('/zoom/${viewModel.activeDrinkId}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
