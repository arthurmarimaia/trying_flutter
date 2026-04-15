import 'dart:async';

import 'package:flutter/material.dart';
import '../models/pet.dart';

enum PetVisualState { normal, happy, sick, sleeping, fainted }

class PetSpriteWidget extends StatefulWidget {
  final List<String> spriteAssets;
  final double size;
  final PetVisualState state;
  final PetType? petType;

  const PetSpriteWidget({
    super.key,
    required this.spriteAssets,
    this.size = 96,
    this.state = PetVisualState.normal,
    this.petType,
  });

  @override
  State<PetSpriteWidget> createState() => _PetSpriteWidgetState();
}

class _PetSpriteWidgetState extends State<PetSpriteWidget>
    with SingleTickerProviderStateMixin {
  late int _currentFrame;
  Timer? _timer;
  late AnimationController _pulseCtrl;
  bool _assetFailed = false;

  Duration get _frameDuration {
    switch (widget.state) {
      case PetVisualState.happy:
        return const Duration(milliseconds: 150);
      case PetVisualState.sleeping:
        return const Duration(milliseconds: 800);
      case PetVisualState.sick:
        return const Duration(milliseconds: 400);
      case PetVisualState.fainted:
        return const Duration(milliseconds: 9999); // effectively stopped
      case PetVisualState.normal:
        return const Duration(milliseconds: 250);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentFrame = 0;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_assetFailed &&
        widget.spriteAssets.length > 1 &&
        widget.state != PetVisualState.fainted) {
      _timer = Timer.periodic(_frameDuration, (_) {
        if (mounted) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % widget.spriteAssets.length;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PetSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final needsRestart = oldWidget.spriteAssets.length != widget.spriteAssets.length ||
        oldWidget.state != widget.state;
    if (needsRestart) {
      _currentFrame = 0;
      _assetFailed = false;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _buildFallback() {
    final emoji = switch (widget.state) {
      PetVisualState.fainted  => '😵',
      PetVisualState.sick     => '🤒',
      PetVisualState.sleeping => '😴',
      // For normal/happy, prefer a type-specific emoji
      _ => switch (widget.petType) {
        PetType.canino => '🐶',
        PetType.reptil => '🦎',
        PetType.slime  => '🟢',
        null           => '🐾',
      },
    };
    return Text(emoji, style: TextStyle(fontSize: widget.size * 0.8));
  }

  ColorFilter? get _colorFilter {
    switch (widget.state) {
      case PetVisualState.fainted:
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]);
      case PetVisualState.sick:
        return const ColorFilter.matrix([
          0.5, 0,    0,    0, 0,
          0,   0.9,  0,    0, 15,
          0,   0,    0.5,  0, 0,
          0,   0,    0,    1, 0,
        ]);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spriteAsset = widget.spriteAssets.isNotEmpty
        ? widget.spriteAssets[_currentFrame]
        : '';

    final filter = _colorFilter;

    Widget sprite;
    if (spriteAsset.isEmpty || _assetFailed) {
      sprite = _buildFallback();
    } else {
      sprite = Image.asset(
        spriteAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Cache the failure so we stop retrying on every frame tick
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_assetFailed) {
              setState(() {
                _assetFailed = true;
                _timer?.cancel();
              });
            }
          });
          return _buildFallback();
        },
      );
    }

    if (filter != null) {
      sprite = ColorFiltered(colorFilter: filter, child: sprite);
    }

    // State overlays
    Widget? badge;
    switch (widget.state) {
      case PetVisualState.sleeping:
        badge = AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) => Opacity(
            opacity: 0.5 + _pulseCtrl.value * 0.5,
            child: child,
          ),
          child: const Text('💤', style: TextStyle(fontSize: 20)),
        );
      case PetVisualState.sick:
        badge = const Text('🤢', style: TextStyle(fontSize: 18));
      case PetVisualState.happy:
        badge = AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) => Opacity(
            opacity: _pulseCtrl.value,
            child: child,
          ),
          child: const Text('✨', style: TextStyle(fontSize: 16)),
        );
      case PetVisualState.fainted:
        badge = const Text('😵', style: TextStyle(fontSize: 20));
      case PetVisualState.normal:
        badge = null;
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          sprite,
          if (badge != null)
            Positioned(
              top: -8,
              right: -8,
              child: badge,
            ),
        ],
      ),
    );
  }
}