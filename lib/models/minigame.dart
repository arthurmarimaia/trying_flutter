enum GameType { memory, speed, jump }

enum GameDifficulty { easy, medium, hard }

class GameResult {
  final GameType type;
  final GameDifficulty difficulty;
  final int score;
  final int coinsReward;
  final int xpReward;
  final int happinessReward;
  final bool completed;
  final DateTime playedAt;

  GameResult({
    required this.type,
    required this.difficulty,
    required this.score,
    required this.coinsReward,
    required this.xpReward,
    required this.happinessReward,
    required this.completed,
    required this.playedAt,
  });

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      type: GameType.values[map['type'] as int],
      difficulty: GameDifficulty.values[map['difficulty'] as int],
      score: map['score'] as int,
      coinsReward: map['coinsReward'] as int,
      xpReward: map['xpReward'] as int,
      happinessReward: map['happinessReward'] as int,
      completed: map['completed'] as bool,
      playedAt: DateTime.parse(map['playedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'difficulty': difficulty.index,
      'score': score,
      'coinsReward': coinsReward,
      'xpReward': xpReward,
      'happinessReward': happinessReward,
      'completed': completed,
      'playedAt': playedAt.toIso8601String(),
    };
  }
}

class MiniGameStats {
  int totalGamesPlayed = 0;
  int totalCoinsEarned = 0;
  int totalXpEarned = 0;
  Map<GameType, int> bestScores = {
    GameType.memory: 0,
    GameType.speed: 0,
    GameType.jump: 0,
  };

  MiniGameStats();

  factory MiniGameStats.fromMap(Map<String, dynamic> map) {
    final stats = MiniGameStats();
    stats.totalGamesPlayed = map['totalGamesPlayed'] as int? ?? 0;
    stats.totalCoinsEarned = map['totalCoinsEarned'] as int? ?? 0;
    stats.totalXpEarned = map['totalXpEarned'] as int? ?? 0;
    final savedScores = map['bestScores'] as Map<String, dynamic>? ?? {};
    stats.bestScores = {
      GameType.memory: savedScores['memory'] as int? ?? 0,
      GameType.speed: savedScores['speed'] as int? ?? 0,
      GameType.jump: savedScores['jump'] as int? ?? 0,
    };
    return stats;
  }

  Map<String, dynamic> toMap() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalCoinsEarned': totalCoinsEarned,
      'totalXpEarned': totalXpEarned,
      'bestScores': {
        'memory': bestScores[GameType.memory] ?? 0,
        'speed': bestScores[GameType.speed] ?? 0,
        'jump': bestScores[GameType.jump] ?? 0,
      },
    };
  }
}
