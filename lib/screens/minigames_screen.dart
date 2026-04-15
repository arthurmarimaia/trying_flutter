import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/minigame.dart';
import '../services/locale_controller.dart';
import 'minigames/memory_game_screen.dart';
import 'minigames/speed_game_screen.dart';
import 'minigames/jump_game_screen.dart';
import 'minigames/reaction_game_screen.dart';

class MiniGamesScreen extends StatefulWidget {
  final Function(GameResult) onGameComplete;
  final MiniGameStats stats;

  const MiniGamesScreen({
    super.key,
    required this.onGameComplete,
    required this.stats,
  });

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> {
  GameDifficulty selectedDifficulty = GameDifficulty.easy;

  void _handleGameEnd(GameResult result) {
    widget.onGameComplete(result);
  }

  void _startGame(GameType gameType) {
    Widget gameScreen;

    switch (gameType) {
      case GameType.memory:
        gameScreen = MemoryGameScreen(
          difficulty: selectedDifficulty,
          onGameEnd: _handleGameEnd,
        );
      case GameType.speed:
        gameScreen = SpeedGameScreen(
          difficulty: selectedDifficulty,
          onGameEnd: _handleGameEnd,
        );
      case GameType.jump:
        gameScreen = JumpGameScreen(
          difficulty: selectedDifficulty,
          onGameEnd: _handleGameEnd,
        );
      case GameType.reaction:
        gameScreen = ReactionGameScreen(
          difficulty: selectedDifficulty,
          onGameEnd: _handleGameEnd,
        );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => gameScreen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.mgTitle),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const Text('💰', style: TextStyle(fontSize: 14)),
              label: Text('${controller.pet.coins}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              visualDensity: VisualDensity.compact,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withAlpha(200),
                      theme.colorScheme.secondary.withAlpha(150),
                    ],
                  ),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.mgStatsHeader, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${s.mgGamesLabel}: ${widget.stats.totalGamesPlayed}'),
                        Text('💰 ${widget.stats.totalCoinsEarned}'),
                        Text('⭐ ${widget.stats.totalXpEarned}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Difficulty Selector
              Text(s.mgDifficulty, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DifficultyButton(
                      label: s.mgEasy,
                      isSelected: selectedDifficulty == GameDifficulty.easy,
                      onTap: () => setState(() => selectedDifficulty = GameDifficulty.easy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DifficultyButton(
                      label: s.mgNormal,
                      isSelected: selectedDifficulty == GameDifficulty.medium,
                      onTap: () => setState(() => selectedDifficulty = GameDifficulty.medium),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DifficultyButton(
                      label: s.mgHard,
                      isSelected: selectedDifficulty == GameDifficulty.hard,
                      onTap: () => setState(() => selectedDifficulty = GameDifficulty.hard),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (controller.minigameHint.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.minigameHint(controller.minigameHint),
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amberAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${s.mgBonusMultiplier}: x${controller.minigameRewardMultiplier.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              // Games
              Text(s.mgChooseGame, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _GameCard(
                title: s.mgMemoryTitle,
                emoji: '🧠',
                description: s.mgMemoryDesc,
                bestScore: widget.stats.bestScores[GameType.memory] ?? 0,
                bestLabel: s.mgBestPrefix,
                onTap: () => _startGame(GameType.memory),
              ),
              const SizedBox(height: 12),
              _GameCard(
                title: s.mgSpeedTitle,
                emoji: '⚡',
                description: s.mgSpeedDesc,
                bestScore: widget.stats.bestScores[GameType.speed] ?? 0,
                bestLabel: s.mgBestPrefix,
                onTap: () => _startGame(GameType.speed),
              ),
              const SizedBox(height: 12),
              _GameCard(
                title: s.mgJumpTitle,
                emoji: '🐕',
                description: s.mgJumpDesc,
                bestScore: widget.stats.bestScores[GameType.jump] ?? 0,
                bestLabel: s.mgBestPrefix,
                onTap: () => _startGame(GameType.jump),
              ),
              const SizedBox(height: 12),
              _GameCard(
                title: s.mgReactionTitle,
                emoji: '⚡',
                description: s.mgReactionDesc,
                bestScore: widget.stats.bestScores[GameType.reaction] ?? 0,
                bestLabel: s.mgBestPrefix,
                onTap: () => _startGame(GameType.reaction),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.amber.withAlpha(220) : Colors.white.withAlpha(80),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final int bestScore;
  final String bestLabel;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.emoji,
    required this.description,
    required this.bestScore,
    required this.bestLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withAlpha(180),
              theme.colorScheme.secondary.withAlpha(120),
            ],
          ),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  if (bestScore > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '$bestLabel: $bestScore',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
