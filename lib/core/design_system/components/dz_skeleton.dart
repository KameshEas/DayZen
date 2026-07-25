import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design_system.dart';

/// Skeleton loader component for async operations.
/// Displays a shimmer animation while data is loading.
class DzSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const DzSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(8));

  /// Card-sized skeleton (for task/entry items).
  factory DzSkeletonLoader.card({Key? key}) => DzSkeletonLoader(
        key: key,
        width: double.infinity,
        height: 80,
        borderRadius: BorderRadius.circular(DzRadius.card),
      );

  /// Compact list item skeleton.
  factory DzSkeletonLoader.listItem({Key? key}) => DzSkeletonLoader(
        key: key,
        width: double.infinity,
        height: 56,
        borderRadius: BorderRadius.circular(DzRadius.card),
      );

  /// Circular avatar skeleton.
  factory DzSkeletonLoader.avatar({Key? key, double size = 48}) =>
      DzSkeletonLoader(
        key: key,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
      );

  /// Full-width banner skeleton.
  factory DzSkeletonLoader.banner({Key? key}) => DzSkeletonLoader(
        key: key,
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(DzRadius.card),
      );


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final baseColor = brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// List of skeleton loaders for loading state UI.
class DzSkeletonList extends StatelessWidget {
  final int itemCount;
  final DzSkeletonLoader Function(int index) itemBuilder;
  final EdgeInsets padding;
  final double spacing;

  const DzSkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  });

  /// List of card-sized skeleton items (common for task/entry lists).
  factory DzSkeletonList.cards({
    Key? key,
    int itemCount = 3,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) =>
      DzSkeletonList(
        key: key,
        itemCount: itemCount,
        itemBuilder: (_) => DzSkeletonLoader.card(),
        padding: padding,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
            child: itemBuilder(index),
          ),
        ),
      ),
    );
  }
}
