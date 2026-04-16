import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo bounce-in
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Title fade + slide up
  late final AnimationController _titleCtrl;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  // Dots pulse (looping)
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    // ── Logo ──────────────────────────────────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = CurvedAnimation(
      parent: _logoCtrl,
      curve: Curves.elasticOut,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // ── Title ─────────────────────────────────────────────────────────────
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleOpacity = CurvedAnimation(
      parent: _titleCtrl,
      curve: Curves.easeIn,
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

    // ── Dots ──────────────────────────────────────────────────────────────
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Sequence: logo first, then title
    _logoCtrl.forward().then((_) {
      if (mounted) _titleCtrl.forward();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Logo ────────────────────────────────────────────────
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🐾', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title ────────────────────────────────────────────────
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        const Text(
                          'Tamagotchi',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cuide do seu pet! 💛',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Bouncing dots ────────────────────────────────────────
                _BouncingDots(controller: _dotsCtrl),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Three bouncing dots ──────────────────────────────────────────────────────

class _BouncingDots extends StatelessWidget {
  final AnimationController controller;
  const _BouncingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        // Each dot starts its bounce at a different phase
        final delay = i * 0.25;
        final animation = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0.0, end: -14.0)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -14.0, end: 0.0)
                .chain(CurveTween(curve: Curves.easeIn)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: ConstantTween(0.0),
            weight: 40,
          ),
        ]).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0)),
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, animation.value),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
