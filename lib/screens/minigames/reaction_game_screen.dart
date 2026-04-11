import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/minigame.dart';
import '../../services/locale_controller.dart';

/// Tap Rápido — targets appear at random positions; tap them before they vanish.
class ReactionGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final Function(GameResult) onGameEnd;

  const ReactionGameScreen({
    super.key,
    required this.difficulty,
    required this.onGameEnd,
  });

  @override
  State<ReactionGameScreen> createState() => _ReactionGameScreenState();
}

class _ReactionGameScreenState extends State<ReactionGameScreen>
    with SingleTickerProviderStateMixin {
  final _rng = Random();

  // Config per difficulty
  int get _gameDuration =>
      widget.difficulty == GameDifficulty.easy ? 30 : widget.difficulty == GameDifficulty.medium ? 25 : 20;
  int get _targetLifeMs =>
      widget.difficulty == GameDifficulty.easy ? 1800 : widget.difficulty == GameDifficulty.medium ? 1300 : 900;
  int get _spawnIntervalMs =>
      widget.difficulty == GameDifficulty.easy ? 1400 : widget.difficulty == GameDifficulty.medium ? 1000 : 700;

  final List<_Target> _targets = [];
  int _score = 0;
  int _missed = 0;
  int _timeLeft = 30;
  bool _started = false;
  bool _gameOver = false;

  Timer? _countdownTimer;
  Timer? _spawnTimer;

  late AnimationController _readyCtrl;
  late Animation<double> _readyScale;
  int _readyCount = 3;
  Timer? _readyTimer;

  final _emojis = ['🐾', '🌟', '💎', '🎯', '🎈', '🍖', '⚡', '❤️', '🎪'];

  @override
  void initState() {
    super.initState();
    _timeLeft = _gameDuration;
    _readyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _readyScale = Tween<double>(begin: 1.4, end: 0.8)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_readyCtrl);
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    _readyTimer?.cancel();
    _readyCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _readyCtrl.forward(from: 0);
    _readyTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_readyCount > 1) {
        setState(() => _readyCount--);
        _readyCtrl.forward(from: 0);
      } else {
        t.cancel();
        setState(() {
          _readyCount = 0;
          _started = true;
        });
        _startGame();
      }
    });
  }

  void _startGame() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() => _timeLeft--);
      }
    });
    _spawnTimer = Timer.periodic(
        Duration(milliseconds: _spawnIntervalMs), (_) => _spawnTarget());
  }

  void _spawnTarget() {
    if (!mounted || _gameOver) return;
    final id = _rng.nextInt(1000000);
    final x = _rng.nextDouble();
    final y = _rng.nextDouble();
    final emoji = _emojis[_rng.nextInt(_emojis.length)];
    setState(() => _targets.add(_Target(id: id, x: x, y: y, emoji: emoji)));

    // Auto-expire after life duration
    Future.delayed(Duration(milliseconds: _targetLifeMs), () {
      if (!mounted) return;
      final stillExists = _targets.any((t) => t.id == id);
      if (stillExists) {
        setState(() {
          _targets.removeWhere((t) => t.id == id);
          _missed++;
        });
      }
    });
  }

  void _tapTarget(int id) {
    HapticFeedback.lightImpact();
    setState(() {
      _targets.removeWhere((t) => t.id == id);
      _score += 10;
    });
  }

  void _endGame() {
    if (_gameOver) return;
    _gameOver = true;
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {});

    final baseCoins = widget.difficulty == GameDifficulty.easy
        ? 12
        : widget.difficulty == GameDifficulty.medium
            ? 22
            : 40;
    final coinsReward = (_score / 10 * (baseCoins / 10)).round().clamp(0, 999);

    widget.onGameEnd(GameResult(
      type: GameType.reaction,
      difficulty: widget.difficulty,
      score: _score,
      coinsReward: coinsReward,
      xpReward: (coinsReward * 0.8).round(),
      happinessReward: 15,
      completed: true,
      playedAt: DateTime.now(),
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final lc = context.read<LocaleController>();
        final s = lc.s;
        final isPt = lc.isPt;
        return AlertDialog(
        title: Text(s.mgGameEndTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${s.mgScoreLabel}: $_score',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${isPt ? 'Acertos' : 'Hits'}: ${_score ~/ 10}  •  ${isPt ? 'Erros' : 'Misses'}: $_missed'),
            const SizedBox(height: 8),
            Text('+$coinsReward 💰  +${(coinsReward * 0.8).round()} ⭐'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(s.mgContinue),
          ),
        ],
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LocaleController>().s.mgReactionAppBar),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '⏱ $_timeLeft s',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score bar
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${context.watch<LocaleController>().s.mgScoreLabel}: $_score',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${context.watch<LocaleController>().s.mgEscapedLabel}: $_missed',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          // Game area
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.shade900,
                        Colors.blue.shade900,
                      ],
                    ),
                  ),
                ),
                // Targets
                if (_started && !_gameOver)
                  ...(_targets.map((t) => _TargetWidget(
                        key: ValueKey(t.id),
                        target: t,
                        onTap: () => _tapTarget(t.id),
                        lifeMs: _targetLifeMs,
                      ))),
                // Countdown overlay
                if (!_started)
                  Center(
                    child: ScaleTransition(
                      scale: _readyScale,
                      child: Text(
                        _readyCount > 0 ? '$_readyCount' : 'JÁ!',
                        style: const TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 12,
                                offset: Offset(2, 2))
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Target {
  final int id;
  final double x;
  final double y;
  final String emoji;
  _Target(
      {required this.id,
      required this.x,
      required this.y,
      required this.emoji});
}

class _TargetWidget extends StatefulWidget {
  const _TargetWidget(
      {super.key,
      required this.target,
      required this.onTap,
      required this.lifeMs});
  final _Target target;
  final VoidCallback onTap;
  final int lifeMs;

  @override
  State<_TargetWidget> createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<_TargetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.lifeMs));
    _scale = Tween<double>(begin: 1.1, end: 0.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final sz = constraints.maxWidth;
      final left = (widget.target.x * (sz - 64)).clamp(4.0, sz - 68.0);
      final top = (widget.target.y *
              (constraints.maxHeight - 64))
          .clamp(4.0, constraints.maxHeight - 68.0);

      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border:
                    Border.all(color: Colors.white54, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 12)
                ],
              ),
              child: Center(
                child: Text(widget.target.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
        ),
      );
    });
  }
}
