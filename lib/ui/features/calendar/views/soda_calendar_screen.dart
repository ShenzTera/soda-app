import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/drink_log.dart';
import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../../../../domain/models/portion_size.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/can_logo_painter.dart';
import '../../../core/widgets/glass_container.dart';
import '../../tracker/view_models/tracker_view_model.dart';

/// Monthly Soda Calendar screen (`/calendar`) with custom-painted Can Logo
/// badges on marked dates, brand color dots, monthly/yearly summary strip,
/// and per-day drink inspection & deletion.
class SodaCalendarScreen extends StatefulWidget {
  const SodaCalendarScreen({super.key});

  @override
  State<SodaCalendarScreen> createState() => _SodaCalendarScreenState();
}

class _SodaCalendarScreenState extends State<SodaCalendarScreen> {
  late int _year;
  late int _month;
  late String _selectedDateKey;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _selectedDateKey = DrinkLog.formatDateKey(now);
  }

  void _stepMonth(int delta) {
    final DateTime next = DateTime(_year, _month + delta, 1);
    setState(() {
      _year = next.year;
      _month = next.month;
      _selectedDateKey = DrinkLog.formatDateKey(next);
    });
  }

  void _jumpToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _year = now.year;
      _month = now.month;
      _selectedDateKey = DrinkLog.formatDateKey(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.watch<TrackerViewModel>();
    final List<DrinkLog> allLogs = viewModel.logs;

    // Group logs by dateKey
    final Map<String, List<DrinkLog>> logsByDate = <String, List<DrinkLog>>{};
    for (final DrinkLog l in allLogs) {
      logsByDate.putIfAbsent(l.dateKey, () => <DrinkLog>[]).add(l);
    }

    final String monthPrefix =
        '${_year.toString().padLeft(4, '0')}-${_month.toString().padLeft(2, '0')}';
    final String yearPrefix = '${_year.toString().padLeft(4, '0')}-';

    int monthTotalCount = 0;
    int monthTotalMl = 0;
    final Set<String> monthActiveDays = <String>{};
    int yearTotalCount = 0;

    for (final DrinkLog l in allLogs) {
      if (l.dateKey.startsWith(monthPrefix)) {
        monthTotalCount++;
        monthTotalMl += l.ml;
        monthActiveDays.add(l.dateKey);
      }
      if (l.dateKey.startsWith(yearPrefix)) {
        yearTotalCount++;
      }
    }

    final DateTime firstOfMonth = DateTime(_year, _month, 1);
    final int daysInMonth = DateTime(_year, _month + 1, 0).day;
    // Monday-first offset (0 = Mon, 6 = Sun)
    final int startOffset = firstOfMonth.weekday - DateTime.monday;
    final String todayKey = viewModel.todayKey;
    final List<DrinkLog> selectedDayLogs =
        logsByDate[_selectedDateKey] ?? const <DrinkLog>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(18),
                backgroundColor: const Color(0xF2080B12),
                child: Column(
                  children: <Widget>[
                    // Top header
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'SODA CALENDAR · MARKED DATES',
                                style: AppTheme.monoStyle(
                                  fontSize: 9.5,
                                  color: const Color(0xFFB8FF01),
                                  letterSpacing: 1.3,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM yyyy').format(firstOfMonth),
                                style: AppTheme.syneStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _stepMonth(-1),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        TextButton(
                          onPressed: _jumpToday,
                          child: Text(
                            'Today',
                            style: AppTheme.monoStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _stepMonth(1),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Month / Year summary strip
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _CalendarStatChip(
                            label: 'ACTIVE DAYS',
                            value: '${monthActiveDays.length}',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CalendarStatChip(
                            label: 'MONTH DRINKS',
                            value: '$monthTotalCount',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CalendarStatChip(
                            label: 'MONTH VOL',
                            value: DrinkStats.formatVolume(monthTotalMl),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _CalendarStatChip(
                            label: '$_year TOTAL',
                            value: '$yearTotalCount',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Weekday headers (Mon - Sun)
                    Row(
                      children: const <String>[
                        'MON',
                        'TUE',
                        'WED',
                        'THU',
                        'FRI',
                        'SAT',
                        'SUN',
                      ].map((String wd) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              wd,
                              style: AppTheme.monoStyle(
                                fontSize: 9.5,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),

                    // Calendar Grid with Can Logo on marked dates
                    Expanded(
                      flex: 5,
                      child: GridView.builder(
                        itemCount: startOffset + daysInMonth,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 0.88,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          if (index < startOffset) {
                            return const SizedBox.shrink();
                          }
                          final int dayNum = index - startOffset + 1;
                          final DateTime cellDate =
                              DateTime(_year, _month, dayNum);
                          final String dk = DrinkLog.formatDateKey(cellDate);
                          final List<DrinkLog> dayLogs =
                              logsByDate[dk] ?? const <DrinkLog>[];
                          final bool hasDrinks = dayLogs.isNotEmpty;
                          final bool isSelected = dk == _selectedDateKey;
                          final bool isToday = dk == todayKey;

                          // Dominant drink for the day's Can Logo color
                          Color dominantColor = Colors.white;
                          final Set<String> presentDrinks = <String>{};
                          if (hasDrinks) {
                            final Map<String, int> counts = <String, int>{};
                            for (final DrinkLog l in dayLogs) {
                              presentDrinks.add(l.drinkId);
                              counts[l.drinkId] =
                                  (counts[l.drinkId] ?? 0) + 1;
                            }
                            String topId = dayLogs.first.drinkId;
                            int topCount = 0;
                            counts.forEach((String k, int c) {
                              if (c > topCount) {
                                topCount = c;
                                topId = k;
                              }
                            });
                            dominantColor = DrinkSpec.byId(topId).accentColor;
                          }

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDateKey = dk),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : hasDrinks
                                        ? dominantColor.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? const Color(0xFF38BDF8)
                                          : hasDrinks
                                              ? dominantColor
                                                  .withValues(alpha: 0.55)
                                              : Colors.white
                                                  .withValues(alpha: 0.08),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        '$dayNum',
                                        style: AppTheme.monoStyle(
                                          fontSize: 10,
                                          color: hasDrinks
                                              ? Colors.white
                                              : Colors.white54,
                                        ),
                                      ),
                                      if (hasDrinks)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: dominantColor,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '${dayLogs.length}',
                                            style: AppTheme.monoStyle(
                                              fontSize: 8.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (hasDrinks) ...<Widget>[
                                    // Custom-painted Soda Can Logo on marked dates
                                    SodaCanLogoIcon(
                                      color: dominantColor,
                                      size: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: presentDrinks.map((String id) {
                                        final Color c =
                                            DrinkSpec.byId(id).accentColor;
                                        return Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: c,
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ] else
                                    const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Selected date detail panel + Quick Log button
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  DateFormat('EEE, MMM d, yyyy').format(
                                    DrinkLog.parseDateKey(_selectedDateKey),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => viewModel.backfillDrinks(
                                    drinkId: viewModel.activeDrinkId,
                                    sizeId: viewModel.selectedSizeId,
                                    count: 1,
                                    isRange: false,
                                    singleDate: DrinkLog.parseDateKey(
                                      _selectedDateKey,
                                    ),
                                    startDate: DateTime.now(),
                                    endDate: DateTime.now(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '+ Log ${viewModel.activeDrink.shortName} Here',
                                      style: AppTheme.monoStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: selectedDayLogs.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No drinks logged on this date.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white
                                              .withValues(alpha: 0.45),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: selectedDayLogs.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 5),
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        final DrinkLog log = selectedDayLogs[i];
                                        final DrinkSpec spec =
                                            DrinkSpec.byId(log.drinkId);
                                        final PortionSize sz =
                                            PortionSize.byId(log.sizeId);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.04),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              SodaCanLogoIcon(
                                                color: spec.accentColor,
                                                size: 13,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${spec.name} · ${sz.name} (${sz.label})',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => viewModel
                                                    .deleteLogById(log.id),
                                                child: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 16,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarStatChip extends StatelessWidget {
  const _CalendarStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: AppTheme.monoStyle(
              fontSize: 8.5,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.syneStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
