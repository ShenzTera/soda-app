import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/drink_spec.dart';
import '../../../../domain/models/drink_stats.dart';
import '../../../../domain/models/portion_size.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../tracker/view_models/tracker_view_model.dart';

/// Add Past Drinks / Backfill modal screen (`/history`).
/// Allows logging how many cans/bottles the user has drunk till now on a single
/// day or distributed across a date range (e.g., Jan 1 -> today).
class BackfillHistoryScreen extends StatefulWidget {
  const BackfillHistoryScreen({super.key});

  @override
  State<BackfillHistoryScreen> createState() => _BackfillHistoryScreenState();
}

class _BackfillHistoryScreenState extends State<BackfillHistoryScreen> {
  String _selectedDrinkId = 'coke';
  String _selectedSizeId = 'can_330';
  int _quantity = 12;
  bool _isRangeMode = true;
  late DateTime _singleDate;
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _singleDate = DateTime(now.year, now.month, now.day);
    _startDate = DateTime(now.year, 1, 1);
    _endDate = DateTime(now.year, now.month, now.day);
    _qtyController = TextEditingController(text: '$_quantity');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _setQuantity(int next) {
    final int clamped = next.clamp(1, 5000);
    setState(() {
      _quantity = clamped;
      _qtyController.text = '$clamped';
    });
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrackerViewModel viewModel = context.read<TrackerViewModel>();
    final DrinkSpec spec = DrinkSpec.byId(_selectedDrinkId);
    final PortionSize size = PortionSize.byId(_selectedSizeId);
    final int totalMl = _quantity * size.ml;
    final double totalCans = totalMl / 330.0;
    final DateFormat fmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xF0080B13),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'BACKFILL & HISTORY',
                                  style: AppTheme.monoStyle(
                                    fontSize: 10,
                                    color: const Color(0xFF38BDF8),
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Add Cans Drunk Till Now',
                                  style: AppTheme.syneStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Log past cans or spread your year-to-date total across the calendar so your Soda Wrapped stays 100% accurate.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Choose Drink
                      Text(
                        '1. CHOOSE DRINK',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: DrinkSpec.all.map((DrinkSpec d) {
                          final bool active = d.id == _selectedDrinkId;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDrinkId = d.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? d.accentColor.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: active
                                          ? d.accentColor
                                          : Colors.white
                                              .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        d.assetPath,
                                        height: 36,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        d.shortName,
                                        style: AppTheme.monoStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 2. Container Size
                      Text(
                        '2. CONTAINER SIZE',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: PortionSize.all.map((PortionSize s) {
                          final bool active = s.id == _selectedSizeId;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSizeId = s.id),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white.withValues(alpha: 0.22)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: active
                                          ? Colors.white
                                          : Colors.white
                                              .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Text(s.emoji),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.label,
                                        style: AppTheme.monoStyle(
                                          fontSize: 10.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // 3. How many cans/bottles?
                      Text(
                        '3. HOW MANY CANS / BOTTLES?',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AppTheme.syneStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                filled: true,
                                fillColor:
                                    Colors.white.withValues(alpha: 0.07),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onChanged: (String v) {
                                final int? parsed = int.tryParse(v);
                                if (parsed != null && parsed > 0) {
                                  setState(
                                    () => _quantity = parsed.clamp(1, 5000),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: <int>[1, 5, 10, 25, 50, 100]
                                  .map((int delta) {
                                return GestureDetector(
                                  onTap: () => _setQuantity(_quantity + delta),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.09),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.16),
                                      ),
                                    ),
                                    child: Text(
                                      '+$delta',
                                      style: AppTheme.monoStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. When did you drink them? (Single day vs Spread over range)
                      Text(
                        '4. WHEN DID YOU DRINK THEM?',
                        style: AppTheme.monoStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _ModeTabButton(
                              label: 'One Specific Day',
                              active: !_isRangeMode,
                              onTap: () => setState(() => _isRangeMode = false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ModeTabButton(
                              label: 'Spread Over Range',
                              active: _isRangeMode,
                              onTap: () => setState(() => _isRangeMode = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (!_isRangeMode)
                        _DateSelectorButton(
                          label: 'DATE',
                          value: fmt.format(_singleDate),
                          onTap: () => _pickDate(
                            initial: _singleDate,
                            onPicked: (DateTime d) =>
                                setState(() => _singleDate = d),
                          ),
                        )
                      else
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _DateSelectorButton(
                                label: 'FROM',
                                value: fmt.format(_startDate),
                                onTap: () => _pickDate(
                                  initial: _startDate,
                                  onPicked: (DateTime d) =>
                                      setState(() => _startDate = d),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DateSelectorButton(
                                label: 'TO',
                                value: fmt.format(_endDate),
                                onTap: () => _pickDate(
                                  initial: _endDate,
                                  onPicked: (DateTime d) =>
                                      setState(() => _endDate = d),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),

                      // Live preview box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: spec.accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: spec.accentColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Adding $_quantity × ${size.label} ${spec.name}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${DrinkStats.formatVolume(totalMl)} (≈ ${DrinkStats.formatEquivalence(totalCans)} cans)',
                              style: AppTheme.monoStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await viewModel.backfillDrinks(
                            drinkId: _selectedDrinkId,
                            sizeId: _selectedSizeId,
                            count: _quantity,
                            isRange: _isRangeMode,
                            singleDate: _singleDate,
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(
                          'Add $_quantity ${spec.shortName} to History & Calendar',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
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
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  const _ModeTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? Colors.white.withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}

class _DateSelectorButton extends StatelessWidget {
  const _DateSelectorButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.event_rounded,
              size: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTheme.monoStyle(
                      fontSize: 8.5,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTheme.monoStyle(
                      fontSize: 11.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
