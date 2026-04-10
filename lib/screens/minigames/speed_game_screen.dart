import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

import '../../controllers/pet_controller.dart';
import '../../models/minigame.dart';

class SpeedGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final Function(GameResult) onGameEnd;

  const SpeedGameScreen({
    super.key,
    required this.difficulty,
    required this.onGameEnd,
  });

  @override
  State<SpeedGameScreen> createState() => _SpeedGameScreenState();
}

class _SpeedGameScreenState extends State<SpeedGameScreen> {
  late Stopwatch stopwatch;
  late Timer gameTimer;
  late int adjustedGameDuration;
  int score = 0;
  int? targetButton;
  List<int> buttonSequence = [];
  int currentStep = 0;
  int level = 1;
  bool gameEnded = false;
  bool animatingButton = false;

  int get gameDuration => adjustedGameDuration;

  int get gridSize => 4;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final controller = Provider.of<PetController>(context, listen: false);
    final baseDuration = widget.difficulty == GameDifficulty.easy
        ? 30
        : widget.difficulty == GameDifficulty.medium
            ? 20
            : 10;
    adjustedGameDuration = max(8, baseDuration + controller.minigameDurationAdjustment);

    stopwatch = Stopwatch()..start();
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (stopwatch.elapsedMilliseconds > gameDuration * 1000) {
        _endGame();
      }
      setState(() {});
    });
    _generateTarget();
  }

  void _generateTarget() {
    targetButton = Random().nextInt(gridSize);
    setState(() {});
  }

  void _onButtonTap(int index) {
    if (gameEnded || animatingButton) return;

    if (index == targetButton) {
      setState(() {
        animatingButton = true;
        score++;
        level = 1 + (score ~/ 5);
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            animatingButton = false;
          });
          _generateTarget();
        }
      });
    } else {
      _endGame();
    }
  }

  void _endGame() {
    stopwatch.stop();
    gameTimer.cancel();
    gameEnded = true;

    final controller = Provider.of<PetController>(context, listen: false);
    int coinsReward = 0;
    int xpReward = 0;

    if (score > 0) {
      int baseReward = widget.difficulty == GameDifficulty.easy
          ? 50
          : widget.difficulty == GameDifficulty.medium
              ? 100
              : 200;

      coinsReward = ((baseReward + score * 5) * controller.minigameRewardMultiplier).round();
      xpReward = ((baseReward + score * 8) * controller.minigameRewardMultiplier).round();
    }

    final result = GameResult(
      type: GameType.speed,
      difficulty: widget.difficulty,
      score: score,
      coinsReward: coinsReward,
      xpReward: xpReward,
      happinessReward: score > 0 ? min(30, score ~/ 2) : 0,
      completed: score > (widget.difficulty == GameDifficulty.easy ? 10 : 15),
      playedAt: DateTime.now(),
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('⏱️ Tempo Esgotado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliques corretos: $score'),
              Text('Nível alcançado: $level'),
              const SizedBox(height: 12),
              Text('💰 Moedas: +${result.coinsReward}'),
              Text('⭐ XP: +${result.xpReward}'),
              Text('😊 Felicidade: +${result.happinessReward}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onGameEnd(result);
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    gameTimer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeRemaining = max(0, gameDuration - (stopwatch.elapsedMilliseconds ~/ 1000));
    final isLowTime = timeRemaining < 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo de Velocidade'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${timeRemaining}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isLowTime ? Colors.red : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [Colors.black87, Colors.deepPurple.shade900]
                : [Colors.purple.shade100, Colors.blue.shade200],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cliques: $score',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nível: $level',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: gridSize,
                    itemBuilder: (context, index) {
                      final isTarget = index == targetButton && !gameEnded;
                      return SpeedGameButton(
                        isTarget: isTarget,
                        onTap: () => _onButtonTap(index),
                        emoji: '🎯',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpeedGameButton extends StatefulWidget {
  final bool isTarget;
  final VoidCallback onTap;
  final String emoji;

  const SpeedGameButton({
    super.key,
    required this.isTarget,
    required this.onTap,
    required this.emoji,
  });

  @override
  State<SpeedGameButton> createState() => _SpeedGameButtonState();
}

class _SpeedGameButtonState extends State<SpeedGameButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    if (widget.isTarget) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SpeedGameButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTarget && !oldWidget.isTarget) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isTarget && oldWidget.isTarget) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isTarget ? Colors.amber.withAlpha(220) : Colors.purple.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isTarget ? Colors.orangeAccent : Colors.white24,
              width: widget.isTarget ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isTarget ? Colors.orange.withAlpha(150) : Colors.black26,
                blurRadius: 12,
                spreadRadius: widget.isTarget ? 4 : 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
      ),
    );
  }
}
