import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Skeleton loader for list items.
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final int? crossAxisCount; // For grid, null for list
  final double height;
  final double width;

  const SkeletonLoader({
    super.key,
    this.itemCount = 3,
    this.crossAxisCount,
    this.height = 100,
    this.width = double.infinity,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.crossAxisCount != null) {
      // Grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount!,
          crossAxisSpacing: DzSpacing.md,
          mainAxisSpacing: DzSpacing.md,
        ),
        itemCount: widget.itemCount,
        itemBuilder: (context, _) => _buildSkeletonItem(),
      );
    }

    // List layout
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      itemBuilder: (context, _) => Padding(
        padding: const EdgeInsets.only(bottom: DzSpacing.md),
        child: _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return _ShimmerWidget(
      shimmerController: _shimmerController,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer effect for skeleton loaders.
class _ShimmerWidget extends StatelessWidget {
  final Widget child;
  final AnimationController shimmerController;

  const _ShimmerWidget({
    required this.child,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                shimmerController.value,
                1.0,
              ],
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Centered loading indicator.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool center;

  const LoadingIndicator({
    super.key,
    this.message,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: DzSpacing.md),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    if (center) {
      return Center(child: content);
    }

    return Padding(
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: content,
    );
  }
}

/// Linear progress indicator with label.
class ProgressIndicatorWithLabel extends StatelessWidget {
  final double value;
  final String? label;
  final bool showPercentage;

  const ProgressIndicatorWithLabel({
    super.key,
    required this.value,
    this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: DzSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (showPercentage)
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Empty state widget.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: DzColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: DzSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DzSpacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: DzSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Network state indicator banner.
class NetworkStateBanner extends StatelessWidget {
  final bool isOnline;
  final String? customMessage;

  const NetworkStateBanner({
    super.key,
    required this.isOnline,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Material(
      color: Colors.orange.shade600,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.md,
          vertical: DzSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: DzSpacing.sm),
            Expanded(
              child: Text(
                customMessage ?? 'No internet connection • Using offline data',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry overlay for failed states.
class RetryOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onRetry;
  final String? message;

  const RetryOverlay({
    super.key,
    required this.isVisible,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(DzSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.withValues(alpha: 0.6),
                ),
                const SizedBox(height: DzSpacing.md),
                Text(
                  message ?? 'Operation failed',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DzSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
