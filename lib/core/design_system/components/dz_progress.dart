import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzSunLoader
// ─────────────────────────────────────────────────────────────────────────────

/// The DayZen sunrise mark as a loader: the sun and horizon stay put while
/// the five rays sweep on and off, left to right, in a loop.
///
/// Two-tone by default (Sunrise sun and rays, themed ink horizon). Use
/// [DzSunLoader.mono] on a filled surface such as a button, where a single
/// foreground color is needed. Holds still when the system asks for reduced
/// motion.
class DzSunLoader extends StatefulWidget {
  const DzSunLoader({super.key, this.width = 56, this.rayColor, this.inkColor});

  /// Single-color variant for filled surfaces.
  const DzSunLoader.mono({super.key, this.width = 56, required Color color})
    : rayColor = color,
      inkColor = color;

  /// Width in logical px; height follows the mark's 432:248 aspect ratio.
  final double width;
  final Color? rayColor;
  final Color? inkColor;

  @override
  State<DzSunLoader> createState() => _DzSunLoaderState();
}

class _DzSunLoaderState extends State<DzSunLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce == _reduceMotion && _controller.isAnimating) return;
    _reduceMotion = reduce;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ray = widget.rayColor ?? DzColors.sunrise;
    final ink = widget.inkColor ?? Theme.of(context).colorScheme.onSurface;
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.width * 248 / 432,
        child: CustomPaint(
          painter: _SunPainter(
            animation: _controller,
            still: _reduceMotion,
            rayColor: ray,
            inkColor: ink,
          ),
        ),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  _SunPainter({
    required this.animation,
    required this.still,
    required this.rayColor,
    required this.inkColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final bool still;
  final Color rayColor;
  final Color inkColor;

  // Ray centerlines from the logo kit's mark (432×248), left to right,
  // as (outer end, inner end nearest the sun).
  static const _rays = [
    (Offset(52, 135), Offset(106, 168)),
    (Offset(118, 68), Offset(152, 118)),
    (Offset(216, 28), Offset(216, 100)),
    (Offset(314, 68), Offset(280, 118)),
    (Offset(380, 135), Offset(326, 168)),
  ];
  static const _sunCenter = Offset(216, 220);
  static const _stroke = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 432, size.height / 248);
    canvas.translate(
      (size.width - 432 * scale) / 2,
      (size.height - 248 * scale) / 2,
    );
    canvas.scale(scale);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _stroke;

    for (var i = 0; i < _rays.length; i++) {
      final b = still ? 1.0 : _pulse((animation.value - i * 0.14) % 1.0);
      final (outer, inner) = _rays[i];
      final tip = Offset.lerp(inner, outer, 0.7 + 0.3 * b)!;
      line.color = rayColor.withValues(alpha: 0.25 + 0.75 * b);
      canvas.drawLine(inner, tip, line);
    }

    line.color = rayColor;
    canvas.drawArc(
      Rect.fromCircle(center: _sunCenter, radius: 78),
      math.pi,
      math.pi,
      false,
      line,
    );

    line.color = inkColor;
    canvas.drawLine(const Offset(32, 220), const Offset(400, 220), line);
  }

  // One smooth 0→1→0 blip per cycle, then rest until the next sweep.
  static double _pulse(double x) =>
      x < 0.35 ? math.sin(math.pi * x / 0.35) : 0.0;

  @override
  bool shouldRepaint(_SunPainter old) =>
      old.still != still ||
      old.rayColor != rayColor ||
      old.inkColor != inkColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// DzCheckMark
// ─────────────────────────────────────────────────────────────────────────────

/// A Sunrise disc that scales in, then draws a navy check mark.
class DzCheckMark extends StatelessWidget {
  const DzCheckMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 700),
        builder: (context, t, _) =>
            CustomPaint(size: Size.square(size), painter: _CheckPainter(t)),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final disc = Curves.easeOutBack.transform((t / 0.5).clamp(0.0, 1.0));
    canvas.drawCircle(
      size.center(Offset.zero),
      radius * disc,
      Paint()..color = DzColors.sunrise,
    );

    final w = size.width;
    final check = Path()
      ..moveTo(w * 0.28, w * 0.52)
      ..lineTo(w * 0.44, w * 0.67)
      ..lineTo(w * 0.72, w * 0.36);
    final progress = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
    final metric = check.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * Curves.easeOut.transform(progress)),
      Paint()
        ..color = DzColors.navy
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.09,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// DzLoadingView
// ─────────────────────────────────────────────────────────────────────────────

/// Page- or card-level loading state: the sun loader with an optional message.
class DzLoadingView extends StatelessWidget {
  const DzLoadingView({super.key, this.message, this.width = 72});

  final String? message;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: message ?? 'Loading',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DzSunLoader(width: width),
            if (message != null) ...[
              const SizedBox(height: DzSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: DzTextStyles.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzProgress — blocking progress overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressView {
  const _ProgressView({required this.message, this.hint, this.success = false});

  final String message;
  final String? hint;
  final bool success;

  _ProgressView withHint(String? value) =>
      _ProgressView(message: message, hint: value, success: success);
}

/// Runs a task behind a blocking, branded progress overlay.
///
/// ```dart
/// final ok = await DzProgress.run<bool>(
///   context,
///   message: 'Signing you in…',
///   successMessage: 'Welcome back',
///   isSuccess: (ok) => ok,
///   task: () => auth.signIn(...),
/// );
/// ```
///
/// - The overlay only appears if the task is still running after [showDelay],
///   so quick operations never flash a dialog. Set [alwaysShow] for explicit
///   user actions that deserve visible confirmation even when instant.
/// - Once shown it stays at least [minVisible] so it can't flicker.
/// - If the task succeeds (no error, and [isSuccess] is true or absent) and
///   [successMessage] is set, the overlay morphs into an animated check for
///   [successHold]. On failure it closes immediately so the screen behind can
///   show the error.
/// - After [slowAfter], [slowHint] appears under the message.
/// - Errors from [task] are rethrown after the overlay closes.
abstract final class DzProgress {
  static Future<T?> run<T>(
    BuildContext context, {
    required String message,
    required Future<T> Function() task,
    String? successMessage,
    bool Function(T result)? isSuccess,
    String? slowHint = 'This is taking longer than usual…',
    Duration slowAfter = const Duration(seconds: 6),
    Duration showDelay = const Duration(milliseconds: 150),
    bool alwaysShow = false,
    Duration minVisible = const Duration(milliseconds: 700),
    Duration successHold = const Duration(milliseconds: 900),
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final view = ValueNotifier(_ProgressView(message: message));

    T? result;
    Object? error;
    StackTrace? stack;
    var done = false;
    final work = task().then<void>(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e, StackTrace s) {
        error = e;
        stack = s;
        done = true;
      },
    );

    if (!alwaysShow) {
      final delayElapsed = Completer<void>();
      final delayTimer = Timer(showDelay, delayElapsed.complete);
      await Future.any([work, delayElapsed.future]);
      delayTimer.cancel();
    }

    Future<void>? dialog;
    if ((alwaysShow || !done) && navigator.mounted) {
      dialog = _show(navigator, view);
      final shownAt = DateTime.now();
      final slow = Timer(slowAfter, () {
        if (!done) view.value = view.value.withHint(slowHint);
      });

      await work;
      slow.cancel();

      final elapsed = DateTime.now().difference(shownAt);
      if (elapsed < minVisible) {
        await Future<void>.delayed(minVisible - elapsed);
      }

      final ok = error == null && (isSuccess?.call(result as T) ?? true);
      if (ok && successMessage != null) {
        view.value = _ProgressView(message: successMessage, success: true);
        await Future<void>.delayed(successHold);
      }
      if (navigator.mounted) navigator.pop();
      await dialog;
    } else {
      await work;
    }

    view.dispose();
    if (error != null) Error.throwWithStackTrace(error!, stack!);
    return result;
  }

  static Future<void> _show(
    NavigatorState navigator,
    ValueNotifier<_ProgressView> view,
  ) {
    return showGeneralDialog<void>(
      context: navigator.context,
      barrierDismissible: false,
      barrierLabel: 'Progress',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, _) => PopScope(
        canPop: false,
        child: Center(child: _ProgressCard(view: view)),
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.view});

  final ValueListenable<_ProgressView> view;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(DzRadius.card + 4);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: scheme.surface,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DzSpacing.lg,
              DzSpacing.xl,
              DzSpacing.lg,
              DzSpacing.lg,
            ),
            child: ValueListenableBuilder<_ProgressView>(
              valueListenable: view,
              builder: (context, v, _) => Semantics(
                liveRegion: true,
                label: v.hint == null ? v.message : '${v.message} ${v.hint}',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 64,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        ),
                        child: v.success
                            ? const DzCheckMark(key: ValueKey('ok'), size: 64)
                            : const DzSunLoader(
                                key: ValueKey('busy'),
                                width: 104,
                              ),
                      ),
                    ),
                    const SizedBox(height: DzSpacing.lg),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        v.message,
                        key: ValueKey(v.message),
                        textAlign: TextAlign.center,
                        style: DzTextStyles.heading3.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      alignment: Alignment.topCenter,
                      child: v.hint == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: DzSpacing.sm),
                              child: Text(
                                v.hint!,
                                textAlign: TextAlign.center,
                                style: DzTextStyles.caption.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
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
