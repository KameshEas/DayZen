import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/components/dz_logo.dart';
import '../../core/design_system/tokens/tokens.dart';

/// Animated brand splash: horizon draws in, sun rises, rays radiate, then the
/// "DayZen" wordmark and "Focus. Reflect. Grow." tagline stagger in.
///
/// The artwork is the kit's `primary` lockup (color on light, reversed on
/// dark), split by element id (`rays`, `sun`, `horizon`, `letter-*`, `tag-*`),
/// so swapping in a re-exported kit file with the same ids needs no code change.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _artSize = Size(991, 630);
  static const _sunCenter = Offset(495.5, 218.28);
  static const _horizonY = 220.3;
  static const _rayDelays = [0, 1, 2, 1, 2];
  static const _letterIds = [
    'letter-d',
    'letter-a',
    'letter-y',
    'letter-z',
    'letter-e',
    'letter-n',
  ];
  static const _tagIds = ['tag-focus', 'tag-reflect', 'tag-grow'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  _SplashArt? _art;
  Timer? _holdTimer;
  bool _finished = false;
  bool _started = false;
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _scheduleFinish(300);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _dark = Theme.of(context).brightness == Brightness.dark;
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(DzLogo.assetPath(
        DzLogoLayout.primary,
        _dark ? DzLogoTone.reversed : DzLogoTone.color,
      ));
      final art = _SplashArt.parse(raw, _letterIds, _tagIds);
      if (!mounted) return;
      setState(() => _art = art);
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
        _scheduleFinish(500);
      } else {
        _controller.forward();
      }
    } catch (_) {
      _finish();
    }
  }

  void _scheduleFinish(int ms) {
    _holdTimer?.cancel();
    _holdTimer = Timer(Duration(milliseconds: ms), _finish);
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double _p(double begin, double end, [Curve curve = Curves.linear]) {
    final t = ((_controller.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final art = _art;
    final width = (MediaQuery.sizeOf(context).width * 0.86).clamp(0.0, 520.0);
    final height = width * _artSize.height / _artSize.width;

    return Scaffold(
      backgroundColor: _dark ? DzColors.navy : DzColors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finish,
        child: Center(
          child: art == null
              ? const SizedBox.shrink()
              : Semantics(
                  label: 'DayZen. Focus. Reflect. Grow.',
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => _buildArt(art),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildArt(_SplashArt art) {
    final horizon = _p(0.0, 0.22, Curves.easeOutCubic);
    final sun = _p(0.10, 0.42, Curves.easeOutCubic);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Sun rises from behind the horizon line (clipped at the horizon).
        ClipRect(
          clipper: _TopClipper(_horizonY / _artSize.height),
          child: FractionalTranslation(
            translation: Offset(0, (1 - sun) * 0.14),
            child: Opacity(opacity: sun.clamp(0.0, 1.0), child: art.sun),
          ),
        ),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(horizon.clamp(0.001, 1.0), 1, 1),
          child: art.horizon,
        ),
        for (var i = 0; i < art.rays.length; i++) _ray(art.rays[i], i),
        for (var i = 0; i < art.letters.length; i++)
          _rise(art.letters[i], 0.50 + i * 0.05, 0.20, 0.05),
        for (var i = 0; i < art.tagline.length; i++)
          _rise(art.tagline[i], 0.70 + i * 0.06, 0.16, 0.03),
      ],
    );
  }

  Widget _ray(Widget ray, int index) {
    final begin = 0.38 + _rayDelays[index] * 0.06;
    final scale = _p(begin, begin + 0.22, Curves.easeOutBack);
    final fade = _p(begin, begin + 0.12).clamp(0.0, 1.0);
    return Opacity(
      opacity: fade,
      child: Transform.scale(
        scale: scale,
        alignment: FractionalOffset(
          _sunCenter.dx / _artSize.width,
          _sunCenter.dy / _artSize.height,
        ),
        child: ray,
      ),
    );
  }

  Widget _rise(Widget child, double begin, double duration, double lift) {
    final t = _p(begin, begin + duration, Curves.easeOutCubic);
    return Opacity(
      opacity: t,
      child: FractionalTranslation(
        translation: Offset(0, (1 - t) * lift),
        child: child,
      ),
    );
  }
}

class _TopClipper extends CustomClipper<Rect> {
  const _TopClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width, size.height * fraction);

  @override
  bool shouldReclip(_TopClipper oldClipper) => oldClipper.fraction != fraction;
}

class _SplashArt {
  const _SplashArt({
    required this.sun,
    required this.horizon,
    required this.rays,
    required this.letters,
    required this.tagline,
  });

  final Widget sun;
  final Widget horizon;
  final List<Widget> rays;
  final List<Widget> letters;
  final List<Widget> tagline;

  static _SplashArt parse(
    String raw,
    List<String> letterIds,
    List<String> tagIds,
  ) {
    final paths = {
      for (final m in RegExp(
        r'<path id="([\w-]+)"(?:\s+fill="[^"]*")?\s+d="([^"]+)"',
      ).allMatches(raw))
        m.group(1)!: m.group(2)!,
    };

    String fillOf(String id) {
      final m = RegExp('<(?:g|path) id="$id"[^>]*?fill="(#[0-9A-Fa-f]+)"')
          .firstMatch(raw);
      return m?.group(1) ?? '#000000';
    }

    Widget layer(String fill, String d) => SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 991 630">'
          '<path fill="$fill" d="$d"/></svg>',
          fit: BoxFit.fill,
        );

    final raysGroup = RegExp(r'<g id="rays"[^>]*>(.*?)</g>', dotAll: true)
        .firstMatch(raw)!
        .group(1)!;
    final rayFill = fillOf('rays');
    final rayPaths = [
      for (final m in RegExp(r'\sd="([^"]+)"').allMatches(raysGroup))
        m.group(1)!,
    ];

    final inkFill = fillOf('wordmark');
    final tagFill = fillOf('tagline');

    return _SplashArt(
      sun: layer(fillOf('sun'), paths['sun']!),
      horizon: layer(fillOf('horizon'), paths['horizon']!),
      rays: [for (final d in rayPaths) layer(rayFill, d)],
      letters: [for (final id in letterIds) layer(inkFill, paths[id]!)],
      tagline: [for (final id in tagIds) layer(tagFill, paths[id]!)],
    );
  }
}
