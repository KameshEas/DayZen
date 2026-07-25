import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../logging/app_logger.dart';

/// Widget that catches and displays errors in a child widget.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.title,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() => _error = details);
      originalOnError?.call(details);
      AppLogger.error('Caught error: ${details.exceptionAsString()}');
    };
  }

  void _retry() {
    setState(() => _error = null);
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Error'),
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DzSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withValues(alpha: 0.6),
                ),
                const SizedBox(height: DzSpacing.lg),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DzSpacing.md),
                Text(
                  _error!.exceptionAsString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (widget.showDetails) ...[
                  const SizedBox(height: DzSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(DzSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _error!.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: DzSpacing.lg),
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Wrapper for async operations with error handling.
class AsyncErrorHandler extends StatelessWidget {
  final AsyncSnapshot<dynamic> snapshot;
  final Widget Function(BuildContext) loadingBuilder;
  final Widget Function(BuildContext, dynamic) builder;
  final Widget Function(BuildContext, dynamic)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncErrorHandler({
    super.key,
    required this.snapshot,
    required this.loadingBuilder,
    required this.builder,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return loadingBuilder(context);

      case ConnectionState.done:
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              _defaultErrorWidget(context, snapshot.error);
        }
        return builder(context, snapshot.data);

      case ConnectionState.active:
      case ConnectionState.none:
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              _defaultErrorWidget(context, snapshot.error);
        }
        return builder(context, snapshot.data);
    }
  }

  Widget _defaultErrorWidget(BuildContext context, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              'Failed to load data',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DzSpacing.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DzSpacing.lg),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
