import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';

import '../../controllers/pet_controller.dart';
import '../../models/minigame.dart';
import '../../services/locale_controller.dart';

class MemoryGameScreen extends StatefulWidget {
  final GameDifficulty difficulty;
  final Function(GameResult) onGameEnd;

  const MemoryGameScreen({
    super.key,
    required this.difficulty,
    required this.onGameEnd,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late List<String> cards;
  late List<bool> revealed;
  late List<bool> matched;
  int? firstIndex;
  int? secondIndex;
  bool isLocked = false;
  int moves = 0;
  int matchedPairs = 0;
  late Stopwatch stopwatch;
  late Timer gameTimer;
  late int allowedTime;
  bool gameEnded = false;

  final emojis = ['🌟', '🎨', '🎯', '🎪', '🎭', '🎸', '🎲', '🎮', '🎬', '🎤', '🎞️', '🎧'];

  int get gridSize => widget.difficulty == GameDifficulty.easy
      ? 8
      : widget.difficulty == GameDifficulty.medium
          ? 12
          : 16;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final controller = Provider.of<PetController>(context, listen: false);
    final pairs = gridSize ~/ 2;
    cards = [...emojis.take(pairs), ...emojis.take(pairs)]..shuffle();
    revealed = List.filled(gridSize, false);
    matched = List.filled(gridSize, false);
    stopwatch = Stopwatch()..start();
    final baseTime = widget.difficulty == GameDifficulty.easy
        ? 60
        : widget.difficulty == GameDifficulty.medium
            ? 50
            : 40;
    allowedTime = max(20, baseTime + controller.minigameDurationAdjustment);
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (gameEnded) return;
      if (stopwatch.elapsedMilliseconds > allowedTime * 1000) {
        _endGame(false);
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    gameTimer.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void _onCardTap(int index) {
    if (isLocked || revealed[index] || matched[index]) return;

    setState(() {
      revealed[index] = true;

      if (firstIndex == null) {
        firstIndex = index;
      } else if (secondIndex == null) {
        secondIndex = index;
        isLocked = true;
        moves++;

        if (cards[firstIndex!] == cards[secondIndex!]) {
          matched[firstIndex!] = true;
          matched[secondIndex!] = true;
          matchedPairs++;
          firstIndex = null;
          secondIndex = null;
          isLocked = false;

          if (matchedPairs == gridSize ~/ 2) {
            _endGame(true);
          }
        } else {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                revealed[firstIndex!] = false;
                revealed[secondIndex!] = false;
                firstIndex = null;
                secondIndex = null;
                isLocked = false;
              });
            }
          });
        }
      }
    });
  }

  void _endGame(bool completed) {
    stopwatch.stop();
    gameTimer.cancel();
    gameEnded = true;

    final controller = Provider.of<PetController>(context, listen: false);
    int coinsReward = 0;
    int xpReward = 0;

    if (completed) {
      final timeBonus = max(0, 300 - stopwatch.elapsedMilliseconds ~/ 1000);
      int baseReward = widget.difficulty == GameDifficulty.easy
          ? 12
          : widget.difficulty == GameDifficulty.medium
              ? 22
              : 40;

      coinsReward = ((baseReward + timeBonus ~/ 6) * controller.minigameRewardMultiplier).round();
      xpReward = ((baseReward + timeBonus ~/ 3) * controller.minigameRewardMultiplier).round();
    }

    final result = GameResult(
      type: GameType.memory,
      difficulty: widget.difficulty,
      score: moves,
      coinsReward: coinsReward,
      xpReward: xpReward,
      happinessReward: completed ? min(30, 15 + (controller.pet.happiness ~/ 30)) : 5,
      completed: completed,
      playedAt: DateTime.now(),
    );

    if (mounted) {
      final s = context.read<LocaleController>().s;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(completed ? s.mgCongrats : s.mgTimeUp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${s.mgMovesLabel}: $moves'),
              Text('${s.mgTimeLabel}: ${(stopwatch.elapsedMilliseconds ~/ 1000).toString()}s'),
              const SizedBox(height: 12),
              Text('${s.mgCoinsLabel}: +$coinsReward'),
              Text('⭐ XP: +$xpReward'),
              Text('${s.mgHappinessLabel}: +${result.happinessReward}'),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<LocaleController>().s.mgMemoryTitle),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${max(0, allowedTime - stopwatch.elapsedMilliseconds ~/ 1000)}s',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: max(0, allowedTime - stopwatch.elapsedMilliseconds ~/ 1000) < 8
                      ? Colors.redAccent
                      : null,
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
              children: [
                Text(
                  'Pares encontrados: $matchedPairs/${gridSize ~/ 2}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Movimentos: $moves',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize == 8 ? 4 : gridSize == 12 ? 4 : 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: gridSize,
                    itemBuilder: (context, index) {
                      return MemoryCard(
                        emoji: cards[index],
                        isRevealed: revealed[index],
                        isMatched: matched[index],
                        onTap: () => _onCardTap(index),
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

class MemoryCard extends StatelessWidget {
  final String emoji;
  final bool isRevealed;
  final bool isMatched;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.emoji,
    required this.isRevealed,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isMatched || isRevealed ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green.withAlpha(100)
              : isRevealed
                  ? Colors.blue.withAlpha(180)
                  : Colors.purple.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isRevealed || isMatched ? 1.0 : 0.0,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }
}
