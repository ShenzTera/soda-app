import 'package:flutter/material.dart';

/// Renders crisp vertical rotated typography (`quarterTurns: 3`) for collapsed
/// accordion strips, equivalent to CSS `writing-mode: vertical-rl; rotate(180deg)`.
class RotatedVerticalText extends StatelessWidget {
  const RotatedVerticalText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}
