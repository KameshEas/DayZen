import 'package:flutter/material.dart';

/// DayZen Shadow Tokens
abstract final class DzShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0,0,0,0.08)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> none = [];

  /// FAB shadow
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x3D3B82F6),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
