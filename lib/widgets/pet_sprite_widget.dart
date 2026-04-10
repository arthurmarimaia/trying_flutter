import 'dart:async';

import 'package:flutter/material.dart';

class PetSpriteWidget extends StatefulWidget {
  final List<String> spriteAssets;
  final double size;
  final Duration frameDuration;

  const PetSpriteWidget({
    super.key,
    required this.spriteAssets,
    this.size = 96,
    this.frameDuration = const Duration(milliseconds: 250),
  });

  @override
  State<PetSpriteWidget> createState() => _PetSpriteWidgetState();
}

class _PetSpriteWidgetState extends State<PetSpriteWidget> {
  late int _currentFrame;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentFrame = 0;
    if (widget.spriteAssets.length > 1) {
      _timer = Timer.periodic(widget.frameDuration, (_) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % widget.spriteAssets.length;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant PetSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spriteAssets.length != widget.spriteAssets.length) {
      _currentFrame = 0;
      _timer?.cancel();
      if (widget.spriteAssets.length > 1) {
        _timer = Timer.periodic(widget.frameDuration, (_) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % widget.spriteAssets.length;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spriteAsset = widget.spriteAssets.isNotEmpty
        ? widget.spriteAssets[_currentFrame]
        : '';

    return Image.asset(
      spriteAsset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          '🐕',
          style: TextStyle(fontSize: widget.size * 0.8),
        );
      },
    );
  }
}