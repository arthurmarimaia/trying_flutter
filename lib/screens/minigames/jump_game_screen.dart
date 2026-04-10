import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

import '../../controllers/pet_controller.dart';
import '../../models/minigame.dart';

class JumpGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final Function(GameResult) onGameEnd;

  const JumpGameScreen({
    super.key,
    required this.difficulty,
    required this.onGameEnd,
  });

  @override
  State<JumpGameScreen> createState() => _JumpGameScreenState();
}

class _JumpGameScreenState extends State<JumpGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController petController;
  int score = 0;
  int lives = 3;
  late int gameSpeed;
  List<Platform> platforms = [];
  late Stopwatch stopwatch;
  late Timer gameTimer;
  bool gameEnded = false;
  double petY = 200;
  double petVelocity = 0;
  static const double gravity = 0.3;
  static const double jumpPower = -12;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<PetController>(context, listen: false);
    gameSpeed = widget.difficulty == GameDifficulty.easy
        ? 2
        : widget.difficulty == GameDifficulty.medium
            ? 3
            : 4;
    gameSpeed += controller.needsAttention ? 1 : 0;

    petController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _initializeGame();
  }

  void _initializeGame() {
    platforms = [
      Platform(x: 75, y: 400),
      Platform(x: 150, y: 300),
      Platform(x: 75, y: 200),
      Platform(x: 150, y: 100),
      Platform(x: 75, y: 0),
    ];

    stopwatch = Stopwatch()..start();
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), _updateGame);
  }

  void _updateGame(Timer timer) {
    if (gameEnded) return;

    setState(() {
      petVelocity += gravity;
      petY += petVelocity;

      // Check collisions com plataformas
      for (final platform in platforms) {
        if (petY + 40 >= platform.y &&
            petY + 40 <= platform.y + 10 &&
            petVelocity > 0 &&
            petX + 30 >= platform.x &&
            petX + 30 <= platform.x + 60) {
          petVelocity = jumpPower;
          score++;
          _animateJump();
        }
      }

      // Remover plataformas que saíram da tela e gerar novas
      platforms.removeWhere((p) => p.y > 500);
      if (platforms.length < 5) {
        final lastY = platforms.last.y;
        final newPlatform = Platform(
          x: Random().nextDouble() * 200,
          y: lastY - 100 - Random().nextDouble() * 50,
        );
        platforms.add(newPlatform);
      }

      // Game over se caiu
      if (petY > 500) {
        lives--;
        if (lives <= 0) {
          _endGame();
        } else {
          _resetPet();
        }
      }
    });
  }

  void _animateJump() {
    petController.forward(from: 0.0);
  }

  void _resetPet() {
    petY = 200;
    petVelocity = 0;
  }

  void _endGame() {
    gameTimer.cancel();
    stopwatch.stop();
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

      coinsReward = ((baseReward + score * 3) * controller.minigameRewardMultiplier).round();
      xpReward = ((baseReward + score * 5) * controller.minigameRewardMultiplier).round();
    }

    final result = GameResult(
      type: GameType.jump,
      difficulty: widget.difficulty,
      score: score,
      coinsReward: coinsReward,
      xpReward: xpReward,
      happinessReward: score > 0 ? min(25, score ~/ 3) : 0,
      completed: score > (widget.difficulty == GameDifficulty.easy ? 8 : 12),
      playedAt: DateTime.now(),
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('🎮 Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plataformas puladas: $score'),
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

  double petX = 100;

  void _onTap() {
    if (!gameEnded) {
      petVelocity = jumpPower;
      _animateJump();
    }
  }

  @override
  void dispose() {
    gameTimer.cancel();
    stopwatch.stop();
    petController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo de Salto'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Vidas: $lives',
                style: theme.textTheme.titleMedium,
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
        child: GestureDetector(
          onTap: _onTap,
          child: Stack(
            children: [
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Text(
                  'Pontos: $score',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ...platforms.map((platform) {
                return Positioned(
                  left: platform.x,
                  top: platform.y,
                  child: Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(220),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Positioned(
                left: petX,
                top: petY,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                    CurvedAnimation(parent: petController, curve: Curves.elasticOut),
                  ),
                  child: const Text('🐕', style: TextStyle(fontSize: 40)),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Text(
                  'Toque para pular',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Platform {
  double x;
  double y;

  Platform({required this.x, required this.y});
}
