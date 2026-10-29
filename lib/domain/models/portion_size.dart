/// Portion size definition matching the web application's 4 container presets.
class PortionSize {
  const PortionSize({
    required this.id,
    required this.label,
    required this.name,
    required this.ml,
    required this.emoji,
  });

  final String id;
  final String label;
  final String name;
  final int ml;
  final String emoji;

  static const PortionSize can330 = PortionSize(
    id: 'can_330',
    label: '330ml',
    name: 'Standard Can',
    ml: 330,
    emoji: '🥫',
  );

  static const PortionSize bottle500 = PortionSize(
    id: 'bottle_500',
    label: '500ml',
    name: '500ml Bottle',
    ml: 500,
    emoji: '🍾',
  );

  static const PortionSize bottle1000 = PortionSize(
    id: 'bottle_1000',
    label: '1L',
    name: '1 Liter Bottle',
    ml: 1000,
    emoji: '🍶',
  );

  static const PortionSize bottle2000 = PortionSize(
    id: 'bottle_2000',
    label: '2L',
    name: '2 Liter Bottle',
    ml: 2000,
    emoji: '🫗',
  );

  static const List<PortionSize> all = <PortionSize>[
    can330,
    bottle500,
    bottle1000,
    bottle2000,
  ];

  static PortionSize byId(String id) {
    return all.firstWhere(
      (PortionSize size) => size.id == id,
      orElse: () => can330,
    );
  }
}
