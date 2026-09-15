import 'package:flutter/material.dart';

/// Animated widget that fades in and slides up when entering the view
class FadeInUp extends StatefulWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = const Duration(milliseconds: 0),
    this.curve = Curves.easeOut,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated widget with scale and fade effects
class ScaleFadeIn extends StatefulWidget {
  const ScaleFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = const Duration(milliseconds: 0),
    this.curve = Curves.elasticOut,
    this.scale = 0.8,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double scale;

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _scaleAnimation = Tween<double>(begin: widget.scale, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated widget with bounce effect
class BounceIn extends StatefulWidget {
  const BounceIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<BounceIn> createState() => _BounceInState();
}

class _BounceInState extends State<BounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// Parallax effect widget for illustration
class ParallaxIllustration extends StatelessWidget {
  const ParallaxIllustration({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
    this.offset = 18,
  });

  final PageController controller;
  final int index;
  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, c) {
          var page = index.toDouble();
          if (controller.hasClients && controller.position.haveDimensions) {
            page = controller.page ?? index.toDouble();
          }
          final drift = (page - index).clamp(-1.0, 1.0);
          return Transform.translate(
            offset: Offset(drift * -offset, 0),
            child: c,
          );
        },
        child: child,
      ),
    );
  }
}

/// Floating animation that bounces up and down
class FloatingAnimation extends StatefulWidget {
  const FloatingAnimation({
    super.key,
    required this.child,
    this.offset = 12,
    this.duration = const Duration(milliseconds: 3000),
  });

  final Widget child;
  final double offset;
  final Duration duration;

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -widget.offset),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _animation.value,
      child: widget.child,
    );
  }
}
