import 'package:flutter/material.dart';

/// Immutable brand specification for each tracked soda.
class DrinkSpec {
  const DrinkSpec({
    required this.id,
    required this.indexLabel,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.tagline,
    required this.badge,
    required this.accentColor,
    required this.secondaryAccent,
    required this.expandedGradientColors,
    required this.collapsedGradientColors,
    required this.assetPath,
  });

  final String id;
  final String indexLabel;
  final String name;
  final String shortName;
  final String subtitle;
  final String tagline;
  final String badge;
  final Color accentColor;
  final Color secondaryAccent;
  final List<Color> expandedGradientColors;
  final List<Color> collapsedGradientColors;
  final String assetPath;

  static const DrinkSpec coke = DrinkSpec(
    id: 'coke',
    indexLabel: '01',
    name: 'Classic',
    shortName: 'Classic',
    subtitle: 'ORIGINAL TASTE · CLASSIC CARAMEL',
    tagline: 'Iconic Spencerian Crimson & Effervescent Bite',
    badge: 'CLASSIC RED',
    accentColor: Color(0xFFF40009),
    secondaryAccent: Color(0xFFFF4D58),
    expandedGradientColors: <Color>[
      Color(0xFFE5191C),
      Color(0xFFC40E12),
    ],
    collapsedGradientColors: <Color>[
      Color(0xFFE5191C),
      Color(0xFFB5090E),
    ],
    assetPath: 'assets/images/coke.png',
  );

  static const DrinkSpec pepsi = DrinkSpec(
    id: 'pepsi',
    indexLabel: '02',
    name: 'Pepsi',
    shortName: 'Pepsi',
    subtitle: 'BOLD CITRUS COLA · ELECTRIC PULSE',
    tagline: 'High-Voltage Cobalt Refreshment & Crisp Finish',
    badge: 'COBALT PULSE',
    accentColor: Color(0xFF005CB4),
    secondaryAccent: Color(0xFF38BDF8),
    expandedGradientColors: <Color>[
      Color(0xFF0B3FD0),
      Color(0xFF0A2DB0),
    ],
    collapsedGradientColors: <Color>[
      Color(0xFF1347D6),
      Color(0xFF0A2AA6),
    ],
    assetPath: 'assets/images/pepsi.png',
  );

  static const DrinkSpec dew = DrinkSpec(
    id: 'dew',
    indexLabel: '03',
    name: 'Mountain Dew',
    shortName: 'Mtn Dew',
    subtitle: 'CITRUS CHARGE · NEON VOLTAGE',
    tagline: 'Radioactive Lime Surge & High-Octane Citrus Kick',
    badge: 'NEON SURGE',
    accentColor: Color(0xFF66CC00),
    secondaryAccent: Color(0xFFB8FF01),
    expandedGradientColors: <Color>[
      Color(0xFF1FA84A),
      Color(0xFF138A3A),
    ],
    collapsedGradientColors: <Color>[
      Color(0xFF22B455),
      Color(0xFF168F3D),
    ],
    assetPath: 'assets/images/dew.png',
  );

  static const List<DrinkSpec> all = <DrinkSpec>[coke, pepsi, dew];

  static DrinkSpec byId(String id) {
    return all.firstWhere(
      (DrinkSpec spec) => spec.id == id,
      orElse: () => coke,
    );
  }
}
